-- Local/disposable RAHA-064 alert payload and protection contract.
begin;

do $$ begin
  if not exists (select 1 from cron.job where jobname = 'raha-064-account-deletion-alert-daily' and schedule = '10 3 * * *') then raise exception 'RAHA-064: alert cron job missing'; end if;
  if has_function_privilege('authenticated', 'public.account_deletion_deadline_alert_payload()', 'execute') then raise exception 'RAHA-064: alert payload exposed to clients'; end if;
  if has_function_privilege('authenticated', 'public.dispatch_account_deletion_deadline_alert()', 'execute') then raise exception 'RAHA-064: alert dispatcher exposed to clients'; end if;
end $$;

insert into public.account_deletion_requests(id,status,policy_version,requested_at,purge_after)
values ('06400000-0000-0000-0000-000000000120','requested','deletion_v2',now()-interval '31 days',now()-interval '2 days');
insert into public.account_deletion_worker_runs(status,started_at,finished_at,error_code)
values ('failed',now()-interval '27 hours',now()-interval '27 hours','WORKER_FAILED');

set local role service_role;
do $$ declare payload jsonb; types jsonb; begin
  payload := public.account_deletion_deadline_alert_payload(); types := payload->'alert_types';
  if not (types ? 'overdue_requests' and types ? 'worker_failed' and types ? 'worker_stale') then raise exception 'RAHA-064: alert classification incomplete'; end if;
  if payload ?| array['user_id','request_id','id','error_code','due_count','overdue_count'] then raise exception 'RAHA-064: alert payload leaked restricted data'; end if;
  if jsonb_object_length(payload) <> 3 then raise exception 'RAHA-064: alert payload has unallowlisted fields'; end if;
end $$;
reset role;
rollback;
