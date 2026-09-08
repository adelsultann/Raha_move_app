-- RAHA-064: profile-settings sync (forward only).
--
-- Product decision: profile settings are saved locally first and synchronized
-- later. The existing sync_push_user_data contract covers check-ins, sessions,
-- feedback, saved routines, and completion, but not preferences. This migration
-- adds a versioned, backward-compatible preference document to the trusted sync
-- contract. It is additive: existing operation kinds are unchanged and older
-- clients remain compatible; new clients opt in by sending the new
-- 'preference_upsert' kind.
--
-- Supported settings (one last-write-wins document):
--   * language            -> public.profiles.preferred_locale
--   * weekly goal         -> public.profiles.weekly_goal_days
--   * permitted positions -> public.user_preferred_positions (set replacement)
--   * sound/vibration     -> public.user_preferences.sound_enabled / .vibration_enabled
--   * Wi-Fi-only downloads-> public.user_preferences.download_on_wifi_only
--   * reminder interest   -> public.user_preferences.reminders_enabled (NEW, opt-in)
--   * telemetry consents  -> public.user_preferences.analytics_consent (NEW, default false)
--                           public.user_preferences.crash_reporting_consent (NEW, default false)
--
-- Privacy/consent rules:
--   * The payload contains no user-entered free text: locale is a constrained
--     value, positions are UUIDs, weekly_goal_days is an integer, and the rest
--     are booleans. display_name, timezone, and any note fields are deliberately
--     excluded from this contract.
--   * Telemetry is disabled by default: both consent columns default false and
--     are only changed when the owner explicitly sends an updated document.
--
-- Conflict semantics (versioned LWW):
--   * The whole document carries a single 'operation_at' (device UTC edit time)
--     and 'contract_version' (currently 'preferences_v1').
--   * An incoming document applies only if its operation_at is strictly newer
--     than the stored operation_at (or no row exists yet); otherwise it is
--     reported 'superseded' and the authoritative state is returned unchanged.
--   * Preferences are not reward/security state, so device-timestamp LWW is
--     acceptable; the server remains authoritative for rewards/streaks/points.
--   * The authoritative document is exposed through the 'preferences' projection
--     on every push and pull response, so devices reconcile to it directly
--     (no append-only change feed is required for a LWW document).
--
-- Ownership: all writes resolve auth.uid() and never accept a target user id;
-- existing RLS owner policies are preserved unchanged.

-- 1. New preference columns (defaults preserve "telemetry off, reminders opt-in").
alter table public.user_preferences
  add column if not exists reminders_enabled boolean not null default false;
alter table public.user_preferences
  add column if not exists analytics_consent boolean not null default false;
alter table public.user_preferences
  add column if not exists crash_reporting_consent boolean not null default false;
alter table public.user_preferences
  add column if not exists operation_at timestamptz;

-- 2. Authoritative preferences document (called only by trusted projection code).
create function public.sync_authoritative_preferences(p_user_id uuid)
returns jsonb language sql stable security definer set search_path = public as $$
  select jsonb_build_object(
    'contract_version', 'preferences_v1',
    'preferred_locale', p.preferred_locale,
    'weekly_goal_days', p.weekly_goal_days,
    'position_ids', coalesce((select jsonb_agg(pp.position_id order by pp.position_id) from public.user_preferred_positions pp where pp.user_id = p_user_id), '[]'::jsonb),
    'sound_enabled', coalesce(up.sound_enabled, true),
    'vibration_enabled', coalesce(up.vibration_enabled, true),
    'download_on_wifi_only', coalesce(up.download_on_wifi_only, true),
    'reminders_enabled', coalesce(up.reminders_enabled, false),
    'analytics_consent', coalesce(up.analytics_consent, false),
    'crash_reporting_consent', coalesce(up.crash_reporting_consent, false),
    'operation_at', up.operation_at,
    'updated_at', up.updated_at
  )
  from public.profiles p
  left join public.user_preferences up on up.user_id = p.user_id
  where p.user_id = p_user_id;
$$;

-- 3. Validation: add the preference_upsert kind.
create or replace function public.sync_validate_push_operation(p_operation jsonb)
returns void language plpgsql stable security definer set search_path = public as $$
declare kind text := p_operation->>'kind'; body jsonb := p_operation->'payload'; active_seconds integer; target_seconds integer; reason text;
begin
  perform public.sync_validate_object_fields(p_operation,array['operation_id','kind','payload'],array['operation_id','kind','payload'],'operation');
  perform public.sync_validate_string(p_operation,'operation_id',36,true);
  perform public.sync_validate_string(p_operation,'kind',32,true);
  if (p_operation->>'operation_id') !~* '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$' then raise exception 'operation_id must be a UUID'; end if;
  if kind = 'check_in_upsert' then
    perform public.sync_validate_object_fields(body,array['id','body_state','goal_id','available_minutes','position_id','started_at','completed_at','body_area_ids'],array['id','body_state','goal_id','available_minutes','started_at','body_area_ids'],'check_in_upsert payload');
    perform public.sync_validate_string(body,'id',36,true); perform public.sync_validate_string(body,'body_state',16,true); perform public.sync_validate_string(body,'goal_id',36,true); perform public.sync_validate_string(body,'started_at',64,true); perform public.sync_validate_string(body,'position_id',36); perform public.sync_validate_string(body,'completed_at',64); perform public.sync_validate_integer(body,'available_minutes',3,15);
    perform public.sync_parse_body_area_ids(body->'body_area_ids');
    if body->>'body_state' not in ('comfortable','stiff','tired','tense') or (body->>'available_minutes')::integer not in (3,5,10,15) then raise exception 'invalid check-in value'; end if;
  elsif kind = 'recommendation_upsert' then
    perform public.sync_validate_object_fields(body,array['id','check_in_id','routine_id','engine_version','rank','score','reason_codes','shown_at','accepted_at','rejected_at','rejection_reason'],array['id','check_in_id','routine_id','engine_version','rank','score','reason_codes','shown_at'],'recommendation_upsert payload');
    perform public.sync_validate_string(body,'id',36,true); perform public.sync_validate_string(body,'check_in_id',36,true); perform public.sync_validate_string(body,'routine_id',36,true); perform public.sync_validate_string(body,'engine_version',64,true);     perform public.sync_validate_string(body,'shown_at',64,true); perform public.sync_validate_string(body,'accepted_at',64); perform public.sync_validate_string(body,'rejected_at',64); perform public.sync_validate_string(body,'rejection_reason',16); perform public.sync_validate_integer(body,'rank',1,100); perform public.sync_validate_integer(body,'score',-1000000,1000000);
    if jsonb_typeof(body->'reason_codes') <> 'array' or jsonb_array_length(body->'reason_codes') > 12 then raise exception 'reason_codes must contain at most 12 values'; end if;
    if exists (select 1 from jsonb_array_elements(body->'reason_codes') value where jsonb_typeof(value) <> 'string') then raise exception 'reason_codes values must be strings of at most 64 bytes'; end if;
    for reason in select value #>> '{}' from jsonb_array_elements(body->'reason_codes') loop if octet_length(reason) not between 1 and 64 then raise exception 'reason_codes values must be strings of at most 64 bytes'; end if; end loop;
    if body ? 'rejection_reason' and body->>'rejection_reason' not in ('too_easy','too_difficult','position','discomfort','other') then raise exception 'invalid rejection_reason'; end if;
  elsif kind = 'session_start' then
    perform public.sync_validate_object_fields(body,array['id','routine_id','routine_version','recommendation_id','source','app_version'],array['id','routine_id','routine_version','source','app_version'],'session_start payload');
    perform public.sync_validate_string(body,'id',36,true); perform public.sync_validate_string(body,'routine_id',36,true); perform public.sync_validate_string(body,'recommendation_id',36); perform public.sync_validate_string(body,'source',16,true); perform public.sync_validate_string(body,'app_version',32,true); perform public.sync_validate_integer(body,'routine_version',1,1000000);
    if body->>'source' not in ('recommendation','explore','saved','repeat','bundled') then raise exception 'invalid session source'; end if;
  elsif kind = 'session_step_upsert' then
    perform public.sync_validate_object_fields(body,array['session_id','routine_step_id','exercise_id_snapshot','position_snapshot','status','target_duration_seconds','active_duration_seconds','skip_requested','started_at','finished_at'],array['session_id','routine_step_id','exercise_id_snapshot','position_snapshot','status','target_duration_seconds','active_duration_seconds'],'session_step_upsert payload');
    perform public.sync_validate_string(body,'session_id',36,true); perform public.sync_validate_string(body,'routine_step_id',36,true); perform public.sync_validate_string(body,'exercise_id_snapshot',36,true); perform public.sync_validate_string(body,'status',16,true); perform public.sync_validate_string(body,'started_at',64); perform public.sync_validate_string(body,'finished_at',64);
    perform public.sync_validate_integer(body,'position_snapshot',1,32767); target_seconds := public.sync_validate_integer(body,'target_duration_seconds',1,86400); active_seconds := public.sync_validate_integer(body,'active_duration_seconds',0,86400);
    if active_seconds > target_seconds then raise exception 'active_duration_seconds must be between 0 and target_duration_seconds'; end if;
    if body->>'status' not in ('pending','completed','partial','skipped') then raise exception 'invalid step status'; end if;
    if body ? 'skip_requested' and jsonb_typeof(body->'skip_requested') <> 'boolean' then raise exception 'skip_requested must be boolean'; end if;
  elsif kind = 'session_finalize' then
    perform public.sync_validate_object_fields(body,array['session_id','completion_policy_version','completed_timezone'],array['session_id','completion_policy_version'],'session_finalize payload');
    perform public.sync_validate_string(body,'session_id',36,true); perform public.sync_validate_string(body,'completion_policy_version',64,true);
    if body ? 'completed_timezone' and nullif(body->>'completed_timezone','') is not null then
      if jsonb_typeof(body->'completed_timezone') <> 'string' then raise exception 'completed_timezone must be a string'; end if;
      if octet_length(body->>'completed_timezone') > 64 then raise exception 'completed_timezone must be at most 64 bytes'; end if;
      if not public.is_valid_iana_timezone(body->>'completed_timezone') then raise exception 'completed_timezone is not a valid IANA timezone'; end if;
    end if;
  elsif kind = 'feedback_upsert' then
    perform public.sync_validate_object_fields(body,array['session_id','rating','uncomfortable_exercise_id','note','created_at'],array['session_id','rating'],'feedback_upsert payload');
    perform public.sync_validate_string(body,'session_id',36,true); perform public.sync_validate_string(body,'rating',32,true); perform public.sync_validate_string(body,'uncomfortable_exercise_id',36); perform public.sync_validate_string(body,'note',500); perform public.sync_validate_string(body,'created_at',64);
    if body->>'rating' not in ('much_better','little_better','same','less_comfortable') then raise exception 'invalid feedback rating'; end if;
  elsif kind = 'saved_routine_set' then
    perform public.sync_validate_object_fields(body,array['routine_id','saved','operation_at'],array['routine_id','saved','operation_at'],'saved_routine_set payload');
    perform public.sync_validate_string(body,'routine_id',36,true); perform public.sync_validate_string(body,'operation_at',64,true);
    if jsonb_typeof(body->'saved') <> 'boolean' then raise exception 'saved must be boolean'; end if;
  elsif kind = 'preference_upsert' then
    perform public.sync_validate_object_fields(body,array['contract_version','operation_at','preferred_locale','weekly_goal_days','position_ids','sound_enabled','vibration_enabled','download_on_wifi_only','reminders_enabled','analytics_consent','crash_reporting_consent'],array['contract_version','operation_at','preferred_locale','weekly_goal_days','position_ids','sound_enabled','vibration_enabled','download_on_wifi_only','reminders_enabled','analytics_consent','crash_reporting_consent'],'preference_upsert payload');
    perform public.sync_validate_string(body,'contract_version',64,true);
    perform public.sync_validate_string(body,'operation_at',64,true);
    if body->>'contract_version' <> 'preferences_v1' then raise exception 'unsupported preferences contract version'; end if;
    if body->>'preferred_locale' not in ('ar','en') then raise exception 'invalid preferred_locale'; end if;
    perform public.sync_validate_integer(body,'weekly_goal_days',1,7);
    if jsonb_typeof(body->'position_ids') <> 'array' or jsonb_array_length(body->'position_ids') > 32 then raise exception 'position_ids must be an array of at most 32 UUIDs'; end if;
    if exists (select 1 from jsonb_array_elements(body->'position_ids') value where jsonb_typeof(value) <> 'string' or value #>> '{}' !~* '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$') then raise exception 'position_ids must contain UUIDs'; end if;
    if jsonb_typeof(body->'sound_enabled') <> 'boolean' then raise exception 'sound_enabled must be boolean'; end if;
    if jsonb_typeof(body->'vibration_enabled') <> 'boolean' then raise exception 'vibration_enabled must be boolean'; end if;
    if jsonb_typeof(body->'download_on_wifi_only') <> 'boolean' then raise exception 'download_on_wifi_only must be boolean'; end if;
    if jsonb_typeof(body->'reminders_enabled') <> 'boolean' then raise exception 'reminders_enabled must be boolean'; end if;
    if jsonb_typeof(body->'analytics_consent') <> 'boolean' then raise exception 'analytics_consent must be boolean'; end if;
    if jsonb_typeof(body->'crash_reporting_consent') <> 'boolean' then raise exception 'crash_reporting_consent must be boolean'; end if;
  else raise exception 'unsupported sync operation kind'; end if;
end $$;

-- 4. Apply: add the preference_upsert branch.
create or replace function public.sync_push_user_data(p_operations jsonb)
returns jsonb language plpgsql security definer set search_path = public as $$
declare
  op jsonb; op_id uuid; op_hash text; kind text; body jsonb; result jsonb := '[]'::jsonb; operation_result jsonb;
  v_session_id uuid; v_routine_id uuid; v_routine_step_id uuid; entity_id uuid; incoming_operation_at timestamptz;
  current_saved public.saved_routines%rowtype; final_status public.session_status; body_area_ids uuid[]; canonical_check_in jsonb;
  preference_positions uuid[]; existing_pref_operation_at timestamptz;
begin
  if auth.uid() is null then raise exception 'authentication required'; end if;
  if jsonb_typeof(p_operations) <> 'array' or jsonb_array_length(p_operations) > 100 or octet_length(p_operations::text) > 262144 then raise exception 'operations must be an array of at most 100 items and 262144 bytes'; end if;
  for op in select value from jsonb_array_elements(p_operations) loop
    if octet_length(op::text) > 8192 then raise exception 'operation exceeds 8192 bytes'; end if;
    perform public.sync_validate_push_operation(op);
    op_id := (op->>'operation_id')::uuid; kind := op->>'kind'; body := op->'payload';
    op_hash := encode(extensions.digest(convert_to(op::text,'UTF8'),'sha256'),'hex');
    select response into operation_result from public.sync_applied_operations where user_id=auth.uid() and operation_id=op_id;
    if found then
      if not exists (select 1 from public.sync_applied_operations x where x.user_id=auth.uid() and x.operation_id=op_id and x.request_hash=op_hash) then raise exception 'operation_id was reused with different content'; end if;
      result := result || jsonb_build_array(operation_result || jsonb_build_object('status','replayed'));
      continue;
    end if;
    operation_result := jsonb_build_object('operation_id',op_id,'status','applied');
    if kind = 'check_in_upsert' then
      entity_id := (body->>'id')::uuid; body_area_ids := public.sync_parse_body_area_ids(body->'body_area_ids');
      if (select count(*) from public.body_areas where id = any(body_area_ids) and active) <> cardinality(body_area_ids) then raise exception 'body_area_ids must reference active body areas'; end if;
      insert into public.check_ins(id,user_id,body_state,goal_id,available_minutes,position_id,started_at,completed_at)
      values (entity_id,auth.uid(),body->>'body_state',(body->>'goal_id')::uuid,(body->>'available_minutes')::smallint,nullif(body->>'position_id','')::uuid,(body->>'started_at')::timestamptz,nullif(body->>'completed_at','')::timestamptz)
      on conflict (id) do update set completed_at=coalesce(excluded.completed_at,public.check_ins.completed_at), body_state=excluded.body_state, goal_id=excluded.goal_id, available_minutes=excluded.available_minutes, position_id=excluded.position_id
      where public.check_ins.user_id=auth.uid();
      if not found then raise exception 'check-in id belongs to another user'; end if;
      delete from public.check_in_body_areas where check_in_id=entity_id;
      insert into public.check_in_body_areas(check_in_id,body_area_id) select entity_id, unnest(body_area_ids);
      canonical_check_in := jsonb_strip_nulls(jsonb_build_object('id',entity_id,'body_state',body->'body_state','goal_id',body->'goal_id','available_minutes',body->'available_minutes','position_id',body->'position_id','started_at',body->'started_at','completed_at',body->'completed_at','body_area_ids',to_jsonb(body_area_ids)));
      perform public.record_user_sync_change('check_in',entity_id,'upsert',canonical_check_in);
    elsif kind = 'recommendation_upsert' then
      entity_id := (body->>'id')::uuid;
      if not exists(select 1 from public.check_ins where id=(body->>'check_in_id')::uuid and user_id=auth.uid()) then raise exception 'recommendation dependency is missing'; end if;
      insert into public.recommendations(id,user_id,check_in_id,routine_id,engine_version,rank,score,reason_codes,shown_at,accepted_at,rejected_at,rejection_reason)
      values (entity_id,auth.uid(),(body->>'check_in_id')::uuid,(body->>'routine_id')::uuid,body->>'engine_version',(body->>'rank')::smallint,(body->>'score')::integer,coalesce(array(select jsonb_array_elements_text(body->'reason_codes')),'{}'),(body->>'shown_at')::timestamptz,nullif(body->>'accepted_at','')::timestamptz,nullif(body->>'rejected_at','')::timestamptz,nullif(body->>'rejection_reason',''))
      on conflict (id) do update set accepted_at=coalesce(excluded.accepted_at,public.recommendations.accepted_at), rejected_at=coalesce(excluded.rejected_at,public.recommendations.rejected_at), rejection_reason=coalesce(excluded.rejection_reason,public.recommendations.rejection_reason)
      where public.recommendations.user_id=auth.uid();
      if not found then raise exception 'recommendation id belongs to another user'; end if;
      perform public.record_user_sync_change('recommendation',entity_id,'upsert',body);
    elsif kind = 'session_start' then
      entity_id := (body->>'id')::uuid; perform public.start_routine_session(entity_id,(body->>'routine_id')::uuid,(body->>'routine_version')::integer,nullif(body->>'recommendation_id','')::uuid,body->>'source',body->>'app_version'); perform public.record_user_sync_change('session',entity_id,'upsert',jsonb_build_object('id',entity_id));
    elsif kind = 'session_step_upsert' then
      v_session_id := (body->>'session_id')::uuid; v_routine_step_id := (body->>'routine_step_id')::uuid;
      if not exists(select 1 from public.routine_sessions where id=v_session_id and user_id=auth.uid() and status='in_progress') then raise exception 'session is missing or terminal'; end if;
      if not public.can_write_own_session_step(v_session_id,v_routine_step_id,(body->>'exercise_id_snapshot')::uuid,(body->>'position_snapshot')::smallint,(body->>'target_duration_seconds')::integer) then raise exception 'session step does not match the session routine'; end if;
      insert into public.session_steps(session_id,routine_step_id,exercise_id_snapshot,position_snapshot,status,target_duration_seconds,active_duration_seconds,skip_requested,started_at,finished_at) values (v_session_id,v_routine_step_id,(body->>'exercise_id_snapshot')::uuid,(body->>'position_snapshot')::smallint,(body->>'status')::public.step_status,(body->>'target_duration_seconds')::integer,(body->>'active_duration_seconds')::integer,coalesce((body->>'skip_requested')::boolean,false),nullif(body->>'started_at','')::timestamptz,nullif(body->>'finished_at','')::timestamptz) on conflict (session_id,routine_step_id) do update set status=excluded.status, active_duration_seconds=greatest(public.session_steps.active_duration_seconds,excluded.active_duration_seconds), skip_requested=public.session_steps.skip_requested or excluded.skip_requested, started_at=coalesce(public.session_steps.started_at,excluded.started_at), finished_at=coalesce(excluded.finished_at,public.session_steps.finished_at) where public.session_steps.status='pending' or public.session_steps.active_duration_seconds <= excluded.active_duration_seconds;
      if not found then raise exception 'session step conflicts with terminal progress'; end if;
      perform public.record_user_sync_change('session_step',v_session_id,'upsert',body);
    elsif kind = 'session_finalize' then
      entity_id := (body->>'session_id')::uuid; final_status := public.complete_routine_session(entity_id,body->>'completion_policy_version');
      if body ? 'completed_timezone' and nullif(body->>'completed_timezone','') is not null then
        update public.routine_sessions set completed_timezone = body->>'completed_timezone'
        where id = entity_id and user_id = auth.uid() and status = 'completed';
      end if;
      operation_result := operation_result || jsonb_build_object('reward_result',public.sync_reward_result(auth.uid(),entity_id,final_status));
      perform public.record_user_sync_change('session',entity_id,'finalize',jsonb_build_object('id',entity_id,'status',final_status));
    elsif kind = 'feedback_upsert' then
      entity_id := (body->>'session_id')::uuid; if not exists(select 1 from public.routine_sessions where id=entity_id and user_id=auth.uid() and status='completed') then raise exception 'feedback requires a completed session'; end if;
      insert into public.session_feedback(session_id,user_id,rating,uncomfortable_exercise_id,note,created_at) values (entity_id,auth.uid(),(body->>'rating')::public.feedback_rating,nullif(body->>'uncomfortable_exercise_id','')::uuid,nullif(body->>'note',''),coalesce(nullif(body->>'created_at','')::timestamptz,now())) on conflict (session_id) do update set rating=excluded.rating, uncomfortable_exercise_id=excluded.uncomfortable_exercise_id, note=excluded.note where public.session_feedback.user_id=auth.uid();
      if not found then raise exception 'feedback belongs to another user'; end if; perform public.record_user_sync_change('feedback',entity_id,'upsert',body - 'note');
    elsif kind = 'saved_routine_set' then
      v_routine_id := (body->>'routine_id')::uuid; incoming_operation_at := (body->>'operation_at')::timestamptz;
      if not exists(select 1 from public.routines where id=v_routine_id and status='published' and access_tier='free' and published_at<=now()) then raise exception 'routine is unavailable'; end if;
      select * into current_saved from public.saved_routines where user_id=auth.uid() and routine_id=v_routine_id for update;
      if not found then insert into public.saved_routines(user_id,routine_id,created_at,updated_at,deleted_at,operation_at) values (auth.uid(),v_routine_id,incoming_operation_at,incoming_operation_at,case when coalesce((body->>'saved')::boolean,false) then null else incoming_operation_at end,incoming_operation_at);
      elsif incoming_operation_at > current_saved.operation_at or (incoming_operation_at = current_saved.operation_at and current_saved.deleted_at is null and not coalesce((body->>'saved')::boolean,false)) then update public.saved_routines set deleted_at=case when coalesce((body->>'saved')::boolean,false) then null else incoming_operation_at end, operation_at=incoming_operation_at where user_id=auth.uid() and routine_id=v_routine_id; end if;
      perform public.record_user_sync_change('saved_routine',v_routine_id,(select case when deleted_at is null then 'upsert' else 'delete' end from public.saved_routines where user_id=auth.uid() and routine_id=v_routine_id),(select jsonb_build_object('routine_id',routine_id,'saved',deleted_at is null,'operation_at',operation_at) from public.saved_routines where user_id=auth.uid() and routine_id=v_routine_id));
    elsif kind = 'preference_upsert' then
      incoming_operation_at := (body->>'operation_at')::timestamptz;
      select array(select distinct value #>> '{}' from jsonb_array_elements(body->'position_ids') value) into preference_positions;
      select operation_at into existing_pref_operation_at from public.user_preferences where user_id = auth.uid();
      if existing_pref_operation_at is null or incoming_operation_at > existing_pref_operation_at then
        if (select count(*) from public.movement_positions where id = any(preference_positions) and active) <> cardinality(preference_positions) then raise exception 'position_ids must reference active positions'; end if;
        insert into public.user_preferences(user_id, sound_enabled, vibration_enabled, download_on_wifi_only, reminders_enabled, analytics_consent, crash_reporting_consent, operation_at)
        values (auth.uid(), (body->>'sound_enabled')::boolean, (body->>'vibration_enabled')::boolean, (body->>'download_on_wifi_only')::boolean, (body->>'reminders_enabled')::boolean, (body->>'analytics_consent')::boolean, (body->>'crash_reporting_consent')::boolean, incoming_operation_at)
        on conflict (user_id) do update set sound_enabled=excluded.sound_enabled, vibration_enabled=excluded.vibration_enabled, download_on_wifi_only=excluded.download_on_wifi_only, reminders_enabled=excluded.reminders_enabled, analytics_consent=excluded.analytics_consent, crash_reporting_consent=excluded.crash_reporting_consent, operation_at=excluded.operation_at;
        update public.profiles set preferred_locale = body->>'preferred_locale', weekly_goal_days = (body->>'weekly_goal_days')::smallint where user_id = auth.uid();
        delete from public.user_preferred_positions where user_id = auth.uid();
        insert into public.user_preferred_positions(user_id, position_id) select auth.uid(), x from unnest(preference_positions) x;
        operation_result := operation_result || jsonb_build_object('preferences', public.sync_authoritative_preferences(auth.uid()));
      else
        operation_result := operation_result || jsonb_build_object('status', 'superseded', 'preferences', public.sync_authoritative_preferences(auth.uid()));
      end if;
    end if;
    insert into public.sync_applied_operations(user_id,operation_id,request_hash,response) values (auth.uid(),op_id,op_hash,operation_result);
    result := result || jsonb_build_array(operation_result);
  end loop;
  return jsonb_build_object('operations',result,'cursor',(select coalesce(max(cursor),0) from public.user_sync_changes where user_id=auth.uid()),'projections',public.sync_authoritative_projections(auth.uid()));
end $$;

-- 5. Expose the authoritative preferences document on every push/pull.
create or replace function public.sync_authoritative_projections(p_user_id uuid)
returns jsonb language sql stable security definer set search_path = public as $$
  select jsonb_build_object(
    'points', coalesce((select jsonb_agg(jsonb_build_object('id',id,'points',points,'reason_code',reason_code,'rule_version',rule_version,'source_type',source_type,'source_id',source_id,'created_at',created_at) order by created_at,id) from public.point_ledger where user_id=p_user_id), '[]'::jsonb),
    'points_balance', coalesce((select sum(points)::integer from public.point_ledger where user_id=p_user_id), 0),
    'weekly_progress', public.weekly_movement_progress(p_user_id),
    'achievements', coalesce((select jsonb_agg(jsonb_build_object('achievement_id',achievement_id,'earned_at',earned_at,'source_id',source_id,'criteria_version',criteria_version) order by earned_at,achievement_id) from public.user_achievements where user_id=p_user_id), '[]'::jsonb),
    'streak', (select jsonb_build_object('current_streak_days',current_streak_days,'longest_streak_days',longest_streak_days,'last_movement_date',last_movement_date,'rule_version',rule_version,'updated_at',updated_at) from public.user_streaks where user_id=p_user_id),
    'entitlements', coalesce((select jsonb_agg(jsonb_build_object('entitlement_key',entitlement_key,'is_active',is_active,'product_id',product_id,'expires_at',expires_at,'environment',environment,'updated_at',updated_at) order by entitlement_key) from public.user_entitlements where user_id=p_user_id), '[]'::jsonb),
    'preferences', public.sync_authoritative_preferences(p_user_id)
  )
$$;

-- 6. Trusted-only ACL. The projection helper is internal (called by security
--    definer push/pull), never client-callable. create or replace preserved the
--    existing grants on sync_validate_push_operation/sync_push_user_data/
--    sync_authoritative_projections, so only the new helper needs revoking.
revoke all on function public.sync_authoritative_preferences(uuid) from public, anon, authenticated;
