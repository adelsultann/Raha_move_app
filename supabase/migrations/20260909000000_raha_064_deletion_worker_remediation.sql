-- RAHA-064 security and operations remediation (forward only).
-- iat is never evidence of re-authentication. New requests are eligible at day
-- 27, leaving daily operations three opportunities to meet the 30-day target.
create extension if not exists pg_cron with schema extensions;

alter table public.account_deletion_requests
  add column attempt_count integer not null default 0 check (attempt_count >= 0),
  add column last_attempt_at timestamptz,
  add column next_attempt_at timestamptz,
  add column last_error_code text check (last_error_code is null or last_error_code ~ '^[A-Z0-9_]{1,64}$');
create index account_deletion_requests_retry_due on public.account_deletion_requests (next_attempt_at) where status = 'requested';

create type public.deletion_processing_outcome as enum ('purged', 'retry_scheduled');
create type public.deletion_worker_run_status as enum ('running', 'completed', 'completed_with_retries', 'failed');
create table public.account_deletion_processing_attempts (
  id bigint generated always as identity primary key,
  request_id uuid not null references public.account_deletion_requests(id) on delete restrict,
  attempted_at timestamptz not null default now(), outcome public.deletion_processing_outcome not null,
  attempt_number integer not null check (attempt_number > 0), retry_after timestamptz,
  error_code text check (error_code is null or error_code ~ '^[A-Z0-9_]{1,64}$'),
  check ((outcome = 'purged' and retry_after is null and error_code is null) or (outcome = 'retry_scheduled' and retry_after is not null and error_code is not null))
);
create index account_deletion_processing_attempts_request_attempted on public.account_deletion_processing_attempts (request_id, attempted_at desc);
create table public.account_deletion_worker_runs (
  id bigint generated always as identity primary key, started_at timestamptz not null default now(), finished_at timestamptz,
  status public.deletion_worker_run_status not null, purged_count integer not null default 0 check (purged_count >= 0),
  retry_scheduled_count integer not null default 0 check (retry_scheduled_count >= 0), due_remaining_count integer not null default 0 check (due_remaining_count >= 0),
  overdue_count integer not null default 0 check (overdue_count >= 0), error_code text check (error_code is null or error_code ~ '^[A-Z0-9_]{1,64}$'),
  check ((status = 'running' and finished_at is null and error_code is null) or (status in ('completed', 'completed_with_retries') and finished_at is not null and error_code is null) or (status = 'failed' and finished_at is not null and error_code is not null))
);
create index account_deletion_worker_runs_started_at on public.account_deletion_worker_runs (started_at desc);
alter table public.account_deletion_processing_attempts enable row level security;
alter table public.account_deletion_worker_runs enable row level security;
revoke all on table public.account_deletion_processing_attempts from public, anon, authenticated;
revoke all on table public.account_deletion_worker_runs from public, anon, authenticated;

-- auth_time wins when supplied. Otherwise every AMR element must be a valid
-- timestamped object; malformed AMR can never fall back to iat.
create or replace function public.assert_recent_authentication(p_max_age interval default interval '15 minutes')
returns void language plpgsql security definer set search_path = public as $$
declare
  claims jsonb := auth.jwt(); now_epoch bigint := extract(epoch from now())::bigint;
  auth_epoch bigint; candidate text; amr_entry jsonb;
begin
  if claims is null or jsonb_typeof(claims) <> 'object' then raise exception 'authentication required'; end if;
  if claims ? 'auth_time' then
    candidate := claims->>'auth_time';
    if candidate is null or candidate !~ '^[0-9]{1,15}$' then raise exception 'authentication timestamp malformed'; end if;
    auth_epoch := candidate::bigint;
  else
    if jsonb_typeof(claims->'amr') <> 'array' or jsonb_array_length(claims->'amr') = 0 then raise exception 'authentication timestamp missing'; end if;
    for amr_entry in select value from jsonb_array_elements(claims->'amr') loop
      candidate := amr_entry->>'timestamp';
      if jsonb_typeof(amr_entry) <> 'object' or candidate is null or candidate !~ '^[0-9]{1,15}$' then raise exception 'authentication timestamp malformed'; end if;
      auth_epoch := greatest(coalesce(auth_epoch, 0), candidate::bigint);
    end loop;
  end if;
  if auth_epoch > now_epoch + 300 then raise exception 'authentication timestamp in the future'; end if;
  if auth_epoch < now_epoch - extract(epoch from p_max_age)::bigint then raise exception 'authentication expired; please re-authenticate'; end if;
end $$;

create or replace function public.request_account_deletion()
returns jsonb language plpgsql security definer set search_path = public as $$
declare v_uid uuid := auth.uid(); req public.account_deletion_requests%rowtype; v_requested_at timestamptz; v_purge_after timestamptz;
begin
  if v_uid is null then raise exception 'authentication required'; end if;
  perform public.assert_recent_authentication();
  select * into req from public.account_deletion_requests where user_id = v_uid and status = 'requested' limit 1;
  if found then return public.account_deletion_envelope(req); end if;
  v_requested_at := now(); v_purge_after := v_requested_at + interval '27 days';
  insert into public.account_deletion_requests(user_id, policy_version, requested_at, purge_after) values (v_uid, 'deletion_v2', v_requested_at, v_purge_after)
  on conflict (user_id) where status = 'requested' do nothing returning * into req;
  if not found then select * into req from public.account_deletion_requests where user_id = v_uid and status = 'requested' limit 1; end if;
  return public.account_deletion_envelope(req);
end $$;

create or replace function public.process_due_account_deletions(p_before timestamptz default now())
returns jsonb language plpgsql security definer set search_path = public as $$
declare req public.account_deletion_requests%rowtype; v_now timestamptz := now(); v_purged integer := 0; v_retried integer := 0; v_retry_at timestamptz;
begin
  if p_before > v_now then raise exception 'cannot process deletions scheduled in the future'; end if;
  for req in select * from public.account_deletion_requests where status = 'requested' and purge_after <= p_before and coalesce(next_attempt_at, purge_after) <= p_before order by purge_after, requested_at, id for update skip locked loop
    begin
      update public.account_deletion_requests set status = 'purged', purged_at = v_now, last_attempt_at = v_now, attempt_count = attempt_count + 1, next_attempt_at = null, last_error_code = null where id = req.id;
      if req.user_id is not null then delete from auth.users where id = req.user_id; end if;
      insert into public.account_deletion_processing_attempts(request_id, outcome, attempt_number) values (req.id, 'purged', req.attempt_count + 1);
      v_purged := v_purged + 1;
    exception when others then
      v_retry_at := v_now + least(interval '1 day', interval '5 minutes' * power(2, least(req.attempt_count, 8)));
      update public.account_deletion_requests set attempt_count = attempt_count + 1, last_attempt_at = v_now, next_attempt_at = v_retry_at, last_error_code = 'DELETE_FAILED' where id = req.id and status = 'requested';
      insert into public.account_deletion_processing_attempts(request_id, outcome, attempt_number, retry_after, error_code) values (req.id, 'retry_scheduled', req.attempt_count + 1, v_retry_at, 'DELETE_FAILED');
      v_retried := v_retried + 1;
    end;
  end loop;
  return jsonb_build_object('version', 'raha_064_deletion_v2', 'purged', v_purged, 'retry_scheduled', v_retried);
end $$;

-- Alert if overdue_count > 0, latest_run_status = failed, or latest_run_at is
-- older than 26 hours. Output is aggregate-only and service-role-only.
create or replace function public.account_deletion_deadline_monitor()
returns jsonb language sql stable security definer set search_path = public as $$
  select jsonb_build_object('version', 'raha_064_deletion_v2',
    'due_count', (select count(*) from public.account_deletion_requests where status = 'requested' and purge_after <= now()),
    'overdue_count', (select count(*) from public.account_deletion_requests where status = 'requested' and requested_at + interval '30 days' <= now()),
    'latest_run_at', (select started_at from public.account_deletion_worker_runs order by started_at desc limit 1),
    'latest_run_status', (select status from public.account_deletion_worker_runs order by started_at desc limit 1));
$$;
create or replace function public.run_scheduled_account_deletion_worker()
returns void language plpgsql security definer set search_path = public as $$
declare v_run_id bigint; v_result jsonb; v_monitor jsonb;
begin
  insert into public.account_deletion_worker_runs(status) values ('running') returning id into v_run_id;
  begin
    v_result := public.process_due_account_deletions(); v_monitor := public.account_deletion_deadline_monitor();
    update public.account_deletion_worker_runs set finished_at = now(), status = case when (v_result->>'retry_scheduled')::integer > 0 then 'completed_with_retries'::public.deletion_worker_run_status else 'completed'::public.deletion_worker_run_status end, purged_count = (v_result->>'purged')::integer, retry_scheduled_count = (v_result->>'retry_scheduled')::integer, due_remaining_count = (v_monitor->>'due_count')::integer, overdue_count = (v_monitor->>'overdue_count')::integer where id = v_run_id;
  exception when others then
    update public.account_deletion_worker_runs set finished_at = now(), status = 'failed', error_code = 'WORKER_FAILED' where id = v_run_id; raise;
  end;
end $$;

revoke all on function public.assert_recent_authentication(interval) from public, anon, authenticated;
revoke all on function public.process_due_account_deletions(timestamptz) from public, anon, authenticated;
revoke all on function public.account_deletion_deadline_monitor() from public, anon, authenticated;
revoke all on function public.run_scheduled_account_deletion_worker() from public, anon, authenticated;
grant execute on function public.process_due_account_deletions(timestamptz) to service_role;
grant execute on function public.account_deletion_deadline_monitor() to service_role;
grant execute on function public.run_scheduled_account_deletion_worker() to service_role;

select cron.unschedule(jobid) from cron.job where jobname = 'raha-064-account-deletion-daily';
select cron.schedule('raha-064-account-deletion-daily', '0 3 * * *', $cron$select public.run_scheduled_account_deletion_worker();$cron$);
