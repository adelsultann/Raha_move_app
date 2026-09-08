-- Local/disposable RAHA-064 scheduled deletion-worker contract.
begin;

do $$ begin
  if not exists (select 1 from pg_extension where extname = 'pg_cron') then raise exception 'RAHA-064: pg_cron extension missing'; end if;
  if not exists (select 1 from cron.job where jobname = 'raha-064-account-deletion-daily' and schedule = '0 3 * * *') then raise exception 'RAHA-064: daily worker job missing'; end if;
  if has_function_privilege('authenticated', 'public.run_scheduled_account_deletion_worker()', 'execute') then raise exception 'RAHA-064: scheduled worker exposed to clients'; end if;
  if has_function_privilege('authenticated', 'public.account_deletion_deadline_monitor()', 'execute') then raise exception 'RAHA-064: monitor exposed to clients'; end if;
end $$;

insert into auth.users (id,aud,role,email,encrypted_password,email_confirmed_at,raw_app_meta_data,raw_user_meta_data,created_at,updated_at)
values ('06400000-0000-0000-0000-000000000010','authenticated','authenticated','raha064-worker@example.test','',now(),'{}','{}',now(),now());
insert into public.account_deletion_requests(id,user_id,status,policy_version,requested_at,purge_after)
values ('06400000-0000-0000-0000-000000000110','06400000-0000-0000-0000-000000000010','requested','deletion_v2',now()-interval '27 days',now()-interval '1 minute');

set local role service_role;
select public.run_scheduled_account_deletion_worker();
do $$ declare health jsonb; begin
  if (select status from public.account_deletion_requests where id = '06400000-0000-0000-0000-000000000110') <> 'purged' then raise exception 'RAHA-064: scheduled worker did not purge due request'; end if;
  if not exists (select 1 from public.account_deletion_processing_attempts where request_id = '06400000-0000-0000-0000-000000000110' and outcome = 'purged' and attempt_number = 1) then raise exception 'RAHA-064: purge outcome was not audited'; end if;
  if not exists (select 1 from public.account_deletion_worker_runs where status = 'completed' and purged_count = 1 and finished_at is not null) then raise exception 'RAHA-064: successful worker run was not audited'; end if;
  health := public.account_deletion_deadline_monitor();
  if (health->>'overdue_count')::integer <> 0 then raise exception 'RAHA-064: unexpected deadline breach'; end if;
end $$;
reset role;

-- A single deletion failure is contained, recorded, and made eligible for a
-- later retry; it must not turn the whole scheduled run into a silent success.
insert into auth.users (id,aud,role,email,encrypted_password,email_confirmed_at,raw_app_meta_data,raw_user_meta_data,created_at,updated_at)
values ('06400000-0000-0000-0000-000000000011','authenticated','authenticated','raha064-retry@example.test','',now(),'{}','{}',now(),now());
insert into public.account_deletion_requests(id,user_id,status,policy_version,requested_at,purge_after)
values ('06400000-0000-0000-0000-000000000111','06400000-0000-0000-0000-000000000011','requested','deletion_v2',now()-interval '27 days',now()-interval '1 minute');
create function public.raha_064_test_block_auth_delete() returns trigger language plpgsql as $$
begin
  if old.id = '06400000-0000-0000-0000-000000000011'::uuid then raise exception 'test deletion failure'; end if;
  return old;
end $$;
create trigger raha_064_test_block_auth_delete before delete on auth.users for each row execute function public.raha_064_test_block_auth_delete();
set local role service_role;
select public.run_scheduled_account_deletion_worker();
reset role;
drop trigger raha_064_test_block_auth_delete on auth.users;
drop function public.raha_064_test_block_auth_delete();
do $$ begin
  if (select status from public.account_deletion_requests where id = '06400000-0000-0000-0000-000000000111') <> 'requested' then raise exception 'RAHA-064: failed deletion was not retained for retry'; end if;
  if (select attempt_count from public.account_deletion_requests where id = '06400000-0000-0000-0000-000000000111') <> 1 then raise exception 'RAHA-064: retry attempt count incorrect'; end if;
  if (select last_error_code from public.account_deletion_requests where id = '06400000-0000-0000-0000-000000000111') <> 'DELETE_FAILED' then raise exception 'RAHA-064: retry failure code missing'; end if;
  if not exists (select 1 from public.account_deletion_processing_attempts where request_id = '06400000-0000-0000-0000-000000000111' and outcome = 'retry_scheduled' and error_code = 'DELETE_FAILED') then raise exception 'RAHA-064: retry outcome was not audited'; end if;
  if not exists (select 1 from public.account_deletion_worker_runs where status = 'completed_with_retries' and retry_scheduled_count = 1) then raise exception 'RAHA-064: retrying worker run was not audited'; end if;
end $$;

rollback;
