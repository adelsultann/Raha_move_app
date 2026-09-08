-- Local/disposable RAHA-064 profile-settings sync contract. Run after
-- `supabase db reset` (all migrations applied). Synthetic identities only;
-- rolls back.
--
--   supabase start && supabase db reset
--   psql "postgresql://postgres:postgres@127.0.0.1:54322/postgres" -v ON_ERROR_STOP=1 -f supabase/tests/raha_064_profile_settings_sync.sql
begin;

insert into auth.users (id,aud,role,email,encrypted_password,email_confirmed_at,raw_app_meta_data,raw_user_meta_data,created_at,updated_at) values
  ('06400000-0000-0000-0000-000000000001','authenticated','authenticated','raha064p-owner@example.test','',now(),'{}','{}',now(),now()),
  ('06400000-0000-0000-0000-000000000002','authenticated','authenticated','raha064p-other@example.test','',now(),'{}','{}',now(),now());
-- Profiles auto-created by the RAHA-030 auth.users trigger.

insert into public.movement_positions(id,key,sort_order,active) values
  ('06400000-0000-0000-0000-000000000201','seated',1,true),
  ('06400000-0000-0000-0000-000000000202','standing',2,true),
  ('06400000-0000-0000-0000-000000000203','floor',3,true),
  ('06400000-0000-0000-0000-000000000204','inactive_pos',4,false);

-- ---------------------------------------------------------------------------
-- Schema and privilege gate.
-- ---------------------------------------------------------------------------
do $$ begin
  if not exists (select 1 from information_schema.columns where table_schema='public' and table_name='user_preferences' and column_name='reminders_enabled') then raise exception 'RAHA-064: reminders_enabled missing'; end if;
  if not exists (select 1 from information_schema.columns where table_schema='public' and table_name='user_preferences' and column_name='analytics_consent') then raise exception 'RAHA-064: analytics_consent missing'; end if;
  if not exists (select 1 from information_schema.columns where table_schema='public' and table_name='user_preferences' and column_name='crash_reporting_consent') then raise exception 'RAHA-064: crash_reporting_consent missing'; end if;
  if not exists (select 1 from information_schema.columns where table_schema='public' and table_name='user_preferences' and column_name='operation_at') then raise exception 'RAHA-064: operation_at missing'; end if;
  if (select column_default from information_schema.columns where table_schema='public' and table_name='user_preferences' and column_name='analytics_consent') <> 'false' then raise exception 'RAHA-064: analytics_consent must default false'; end if;
  if (select column_default from information_schema.columns where table_schema='public' and table_name='user_preferences' and column_name='crash_reporting_consent') <> 'false' then raise exception 'RAHA-064: crash_reporting_consent must default false'; end if;
  if (select column_default from information_schema.columns where table_schema='public' and table_name='user_preferences' and column_name='reminders_enabled') <> 'false' then raise exception 'RAHA-064: reminders_enabled must default false'; end if;
  if has_function_privilege('authenticated','public.sync_authoritative_preferences(uuid)','execute') then raise exception 'RAHA-064: preferences projection exposed to clients'; end if;
  if not has_function_privilege('authenticated','public.sync_push_user_data(jsonb)','execute') then raise exception 'RAHA-064: sync push missing'; end if;
end $$;

-- ---------------------------------------------------------------------------
-- Defaults for a fresh user (no user_preferences row): telemetry off, reminders
-- off, device prefs at their safe defaults.
-- ---------------------------------------------------------------------------
set local role authenticated;
select set_config('request.jwt.claim.sub','06400000-0000-0000-0000-000000000002',true);
do $$ declare pr jsonb; begin
  pr := public.sync_pull_user_data(0,100)->'projections'->'preferences';
  if pr->>'contract_version' <> 'preferences_v1' then raise exception 'RAHA-064: projection contract version wrong'; end if;
  if pr->>'preferred_locale' <> 'ar' then raise exception 'RAHA-064: default locale wrong'; end if;
  if (pr->>'weekly_goal_days')::int <> 3 then raise exception 'RAHA-064: default weekly goal wrong'; end if;
  if pr->'position_ids' <> '[]'::jsonb then raise exception 'RAHA-064: default positions not empty'; end if;
  if pr->>'analytics_consent' <> 'false' then raise exception 'RAHA-064: analytics must default off'; end if;
  if pr->>'crash_reporting_consent' <> 'false' then raise exception 'RAHA-064: crash reporting must default off'; end if;
  if pr->>'reminders_enabled' <> 'false' then raise exception 'RAHA-064: reminders must default off'; end if;
end $$;
reset role;

-- ---------------------------------------------------------------------------
-- Happy path: full document applies across profiles + user_preferences +
-- user_preferred_positions, and is reflected in the operation and projections.
-- ---------------------------------------------------------------------------
set local role authenticated;
select set_config('request.jwt.claim.sub','06400000-0000-0000-0000-000000000001',true);
do $$ declare r jsonb; begin
  r := public.sync_push_user_data(jsonb_build_array(jsonb_build_object(
    'operation_id','06400000-0000-0000-0000-000000000301',
    'kind','preference_upsert',
    'payload', jsonb_build_object(
      'contract_version','preferences_v1',
      'operation_at','2026-09-06T10:00:00Z',
      'preferred_locale','en',
      'weekly_goal_days',5,
      'position_ids', jsonb_build_array('06400000-0000-0000-0000-000000000201','06400000-0000-0000-0000-000000000202'),
      'sound_enabled',false,
      'vibration_enabled',false,
      'download_on_wifi_only',false,
      'reminders_enabled',true,
      'analytics_consent',true,
      'crash_reporting_consent',false
    ))));
  if r #>> '{operations,0,status}' <> 'applied' then raise exception 'RAHA-064: expected applied'; end if;
  if r #>> '{operations,0,preferences,preferred_locale}' <> 'en' then raise exception 'RAHA-064: locale not applied'; end if;
  if r #>> '{operations,0,preferences,weekly_goal_days}' <> '5' then raise exception 'RAHA-064: goal not applied'; end if;
  if jsonb_array_length(r #> '{operations,0,preferences,position_ids}') <> 2 then raise exception 'RAHA-064: positions not applied'; end if;
  if r #>> '{operations,0,preferences,analytics_consent}' <> 'true' then raise exception 'RAHA-064: analytics consent not applied'; end if;
  if r #>> '{projections,preferences,preferred_locale}' <> 'en' then raise exception 'RAHA-064: projection missing preferences'; end if;
  if r #>> '{projections,preferences,crash_reporting_consent}' <> 'false' then raise exception 'RAHA-064: crash consent incorrect'; end if;
end $$;
reset role;
do $$ begin
  if (select preferred_locale from public.profiles where user_id='06400000-0000-0000-0000-000000000001') <> 'en' then raise exception 'RAHA-064: profile locale not persisted'; end if;
  if (select weekly_goal_days from public.profiles where user_id='06400000-0000-0000-0000-000000000001') <> 5 then raise exception 'RAHA-064: weekly goal not persisted'; end if;
  if (select sound_enabled from public.user_preferences where user_id='06400000-0000-0000-0000-000000000001') <> false then raise exception 'RAHA-064: sound not persisted'; end if;
  if (select analytics_consent from public.user_preferences where user_id='06400000-0000-0000-0000-000000000001') <> true then raise exception 'RAHA-064: analytics consent not persisted'; end if;
  if (select count(*) from public.user_preferred_positions where user_id='06400000-0000-0000-0000-000000000001') <> 2 then raise exception 'RAHA-064: positions not persisted'; end if;
end $$;

-- ---------------------------------------------------------------------------
-- Idempotency: replaying the same operation_id is a no-op re-apply.
-- ---------------------------------------------------------------------------
set local role authenticated;
select set_config('request.jwt.claim.sub','06400000-0000-0000-0000-000000000001',true);
do $$ declare r jsonb; begin
  r := public.sync_push_user_data(jsonb_build_array(jsonb_build_object(
    'operation_id','06400000-0000-0000-0000-000000000301',
    'kind','preference_upsert',
    'payload', jsonb_build_object(
      'contract_version','preferences_v1','operation_at','2026-09-06T10:00:00Z',
      'preferred_locale','en','weekly_goal_days',5,
      'position_ids', jsonb_build_array('06400000-0000-0000-0000-000000000201','06400000-0000-0000-0000-000000000202'),
      'sound_enabled',false,'vibration_enabled',false,'download_on_wifi_only',false,
      'reminders_enabled',true,'analytics_consent',true,'crash_reporting_consent',false))));
  if r #>> '{operations,0,status}' <> 'replayed' then raise exception 'RAHA-064: replay not detected'; end if;
end $$;
reset role;

-- ---------------------------------------------------------------------------
-- LWW: an older operation_at is superseded and does not overwrite.
-- ---------------------------------------------------------------------------
set local role authenticated;
select set_config('request.jwt.claim.sub','06400000-0000-0000-0000-000000000001',true);
do $$ declare r jsonb; begin
  r := public.sync_push_user_data(jsonb_build_array(jsonb_build_object(
    'operation_id','06400000-0000-0000-0000-000000000302',
    'kind','preference_upsert',
    'payload', jsonb_build_object(
      'contract_version','preferences_v1','operation_at','2026-09-05T10:00:00Z',
      'preferred_locale','ar','weekly_goal_days',1,
      'position_ids', '[]'::jsonb,
      'sound_enabled',true,'vibration_enabled',true,'download_on_wifi_only',true,
      'reminders_enabled',false,'analytics_consent',false,'crash_reporting_consent',true))));
  if r #>> '{operations,0,status}' <> 'superseded' then raise exception 'RAHA-064: expected superseded'; end if;
  if r #>> '{operations,0,preferences,preferred_locale}' <> 'en' then raise exception 'RAHA-064: superseded leaked authoritative state'; end if;
end $$;
reset role;
do $$ begin
  if (select preferred_locale from public.profiles where user_id='06400000-0000-0000-0000-000000000001') <> 'en' then raise exception 'RAHA-064: stale edit overwrote locale'; end if;
end $$;

-- ---------------------------------------------------------------------------
-- Position set replacement (including clearing to empty).
-- ---------------------------------------------------------------------------
set local role authenticated;
select set_config('request.jwt.claim.sub','06400000-0000-0000-0000-000000000001',true);
do $$ begin
  perform public.sync_push_user_data(jsonb_build_array(jsonb_build_object(
    'operation_id','06400000-0000-0000-0000-000000000303','kind','preference_upsert',
    'payload', jsonb_build_object(
      'contract_version','preferences_v1','operation_at','2026-09-06T11:00:00Z',
      'preferred_locale','en','weekly_goal_days',5,
      'position_ids', jsonb_build_array('06400000-0000-0000-0000-000000000203'),
      'sound_enabled',false,'vibration_enabled',false,'download_on_wifi_only',false,
      'reminders_enabled',true,'analytics_consent',true,'crash_reporting_consent',false))));
  if (select count(*) from public.user_preferred_positions where user_id='06400000-0000-0000-0000-000000000001') <> 1 then raise exception 'RAHA-064: positions not replaced'; end if;
  if not exists (select 1 from public.user_preferred_positions where user_id='06400000-0000-0000-0000-000000000001' and position_id='06400000-0000-0000-0000-000000000203') then raise exception 'RAHA-064: replacement position wrong'; end if;

  perform public.sync_push_user_data(jsonb_build_array(jsonb_build_object(
    'operation_id','06400000-0000-0000-0000-000000000304','kind','preference_upsert',
    'payload', jsonb_build_object(
      'contract_version','preferences_v1','operation_at','2026-09-06T12:00:00Z',
      'preferred_locale','en','weekly_goal_days',5,
      'position_ids', '[]'::jsonb,
      'sound_enabled',false,'vibration_enabled',false,'download_on_wifi_only',false,
      'reminders_enabled',true,'analytics_consent',true,'crash_reporting_consent',false))));
  if (select count(*) from public.user_preferred_positions where user_id='06400000-0000-0000-0000-000000000001') <> 0 then raise exception 'RAHA-064: positions not cleared'; end if;
end $$;
reset role;

-- ---------------------------------------------------------------------------
-- Validation: malformed payloads are rejected before any write.
-- ---------------------------------------------------------------------------
set local role authenticated;
select set_config('request.jwt.claim.sub','06400000-0000-0000-0000-000000000001',true);
do $$ begin
  begin
    perform public.sync_push_user_data(jsonb_build_array(jsonb_build_object('operation_id','06400000-0000-0000-0000-000000000311','kind','preference_upsert','payload', jsonb_build_object('contract_version','preferences_v2','operation_at','2026-09-07T00:00:00Z','preferred_locale','en','weekly_goal_days',3,'position_ids','[]'::jsonb,'sound_enabled',true,'vibration_enabled',true,'download_on_wifi_only',true,'reminders_enabled',false,'analytics_consent',false,'crash_reporting_consent',false))));
    raise exception 'RAHA-064: bad contract version accepted';
  exception when raise_exception then if sqlerrm <> 'unsupported preferences contract version' then raise; end if; end;

  begin
    perform public.sync_push_user_data(jsonb_build_array(jsonb_build_object('operation_id','06400000-0000-0000-0000-000000000312','kind','preference_upsert','payload', jsonb_build_object('contract_version','preferences_v1','operation_at','2026-09-07T00:00:00Z','preferred_locale','fr','weekly_goal_days',3,'position_ids','[]'::jsonb,'sound_enabled',true,'vibration_enabled',true,'download_on_wifi_only',true,'reminders_enabled',false,'analytics_consent',false,'crash_reporting_consent',false))));
    raise exception 'RAHA-064: bad locale accepted';
  exception when raise_exception then if sqlerrm <> 'invalid preferred_locale' then raise; end if; end;

  begin
    perform public.sync_push_user_data(jsonb_build_array(jsonb_build_object('operation_id','06400000-0000-0000-0000-000000000313','kind','preference_upsert','payload', jsonb_build_object('contract_version','preferences_v1','operation_at','2026-09-07T00:00:00Z','preferred_locale','en','weekly_goal_days',9,'position_ids','[]'::jsonb,'sound_enabled',true,'vibration_enabled',true,'download_on_wifi_only',true,'reminders_enabled',false,'analytics_consent',false,'crash_reporting_consent',false))));
    raise exception 'RAHA-064: out-of-range goal accepted';
  exception when raise_exception then if sqlerrm <> 'weekly_goal_days must be between 1 and 7' then raise; end if; end;

  begin
    perform public.sync_push_user_data(jsonb_build_array(jsonb_build_object('operation_id','06400000-0000-0000-0000-000000000314','kind','preference_upsert','payload', jsonb_build_object('contract_version','preferences_v1','operation_at','2026-09-07T00:00:00Z','preferred_locale','en','weekly_goal_days',3,'position_ids', jsonb_build_array('not-a-uuid'),'sound_enabled',true,'vibration_enabled',true,'download_on_wifi_only',true,'reminders_enabled',false,'analytics_consent',false,'crash_reporting_consent',false))));
    raise exception 'RAHA-064: bad position id accepted';
  exception when raise_exception then if sqlerrm <> 'position_ids must contain UUIDs' then raise; end if; end;

  begin
    perform public.sync_push_user_data(jsonb_build_array(jsonb_build_object('operation_id','06400000-0000-0000-0000-000000000315','kind','preference_upsert','payload', jsonb_build_object('contract_version','preferences_v1','operation_at','2026-09-07T00:00:00Z','preferred_locale','en','weekly_goal_days',3,'position_ids', jsonb_build_array('06400000-0000-0000-0000-000000000204'),'sound_enabled',true,'vibration_enabled',true,'download_on_wifi_only',true,'reminders_enabled',false,'analytics_consent',false,'crash_reporting_consent',false))));
    raise exception 'RAHA-064: inactive position accepted';
  exception when raise_exception then if sqlerrm <> 'position_ids must reference active positions' then raise; end if; end;

  begin
    perform public.sync_push_user_data(jsonb_build_array(jsonb_build_object('operation_id','06400000-0000-0000-0000-000000000316','kind','preference_upsert','payload', jsonb_build_object('contract_version','preferences_v1','operation_at','2026-09-07T00:00:00Z','preferred_locale','en','weekly_goal_days',3,'position_ids','[]'::jsonb,'sound_enabled','yes','vibration_enabled',true,'download_on_wifi_only',true,'reminders_enabled',false,'analytics_consent',false,'crash_reporting_consent',false))));
    raise exception 'RAHA-064: non-boolean accepted';
  exception when raise_exception then if sqlerrm <> 'sound_enabled must be boolean' then raise; end if; end;
end $$;
reset role;

-- ---------------------------------------------------------------------------
-- Owner isolation: another user neither sees nor mutates the owner's prefs.
-- ---------------------------------------------------------------------------
set local role authenticated;
select set_config('request.jwt.claim.sub','06400000-0000-0000-0000-000000000002',true);
do $$ declare pr jsonb; begin
  pr := public.sync_pull_user_data(0,100)->'projections'->'preferences';
  if pr->>'preferred_locale' <> 'ar' then raise exception 'RAHA-064: other user saw owner locale'; end if;
end $$;
do $$ begin
  if exists (select 1 from public.user_preferences where user_id='06400000-0000-0000-0000-000000000002') then raise exception 'RAHA-064: other user unexpectedly has preferences'; end if;
end $$;
reset role;
do $$ begin
  if (select preferred_locale from public.profiles where user_id='06400000-0000-0000-0000-000000000001') <> 'en' then raise exception 'RAHA-064: owner data altered by other user'; end if;
end $$;

rollback;
