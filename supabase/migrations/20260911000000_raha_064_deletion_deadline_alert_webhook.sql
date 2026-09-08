-- RAHA-064 protected deletion-deadline alert dispatch (forward only).
-- Secret values are deployment-owned Vault/Edge secrets, never migration data.
create extension if not exists pg_net with schema extensions;
create extension if not exists supabase_vault with schema vault;

-- This is the only payload shape permitted across the database/Edge boundary.
-- It deliberately contains no user ID, request ID, error text, or counts.
create or replace function public.account_deletion_deadline_alert_payload()
returns jsonb language sql stable security definer set search_path = public as $$
  with health as (
    select
      exists (select 1 from public.account_deletion_requests where status = 'requested' and requested_at + interval '30 days' <= now()) as overdue,
      (select status from public.account_deletion_worker_runs order by started_at desc limit 1) = 'failed' as worker_failed,
      not exists (select 1 from public.account_deletion_worker_runs where status in ('completed', 'completed_with_retries') and finished_at >= now() - interval '26 hours') as worker_stale
  )
  select jsonb_build_object(
    'version', 'raha_064_deletion_alert_v1',
    'observed_at', now(),
    'alert_types', to_jsonb(array_remove(array[
      case when overdue then 'overdue_requests' end,
      case when worker_failed then 'worker_failed' end,
      case when worker_stale then 'worker_stale' end
    ], null))
  ) from health;
$$;

-- Enqueues an authenticated call only when there is an alert condition. The
-- monitor URL and bearer token are read at execution from Supabase Vault.
create or replace function public.dispatch_account_deletion_deadline_alert()
returns void language plpgsql security definer set search_path = public as $$
declare v_payload jsonb; v_url text; v_token text;
begin
  v_payload := public.account_deletion_deadline_alert_payload();
  if jsonb_array_length(v_payload->'alert_types') = 0 then return; end if;
  select decrypted_secret into v_url from vault.decrypted_secrets where name = 'raha_064_alert_monitor_url' limit 1;
  select decrypted_secret into v_token from vault.decrypted_secrets where name = 'raha_064_alert_dispatch_token' limit 1;
  if coalesce(v_url, '') = '' or coalesce(v_token, '') = '' then
    raise exception 'account deletion alert configuration missing';
  end if;
  perform net.http_post(
    url := v_url,
    headers := jsonb_build_object('content-type', 'application/json', 'authorization', 'Bearer ' || v_token),
    body := v_payload
  );
end $$;

revoke all on function public.account_deletion_deadline_alert_payload() from public, anon, authenticated;
revoke all on function public.dispatch_account_deletion_deadline_alert() from public, anon, authenticated;
grant execute on function public.account_deletion_deadline_alert_payload() to service_role;
grant execute on function public.dispatch_account_deletion_deadline_alert() to service_role;

-- Keep the deletion worker's 03:00 job unchanged. A separate 03:10 monitor
-- also catches a failed/missed worker without making deletion processing depend
-- on network delivery.
select cron.unschedule(jobid) from cron.job where jobname = 'raha-064-account-deletion-alert-daily';
select cron.schedule('raha-064-account-deletion-alert-daily', '10 3 * * *', $cron$select public.dispatch_account_deletion_deadline_alert();$cron$);
