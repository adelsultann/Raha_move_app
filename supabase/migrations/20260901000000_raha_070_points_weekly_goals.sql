-- RAHA-070: points and weekly goals (forward only).
--
-- Approved policy (docs/decisions/raha-070-points-and-weekly-goals.md):
--   * points_completion_v1 awards 10 points for each RAHA-001 qualifying
--     completed session, once per session_id. Abandoned and in-progress
--     sessions earn nothing. Every award persists its rule version.
--   * movement_day_v1 counts a movement day as a local calendar day containing
--     at least one qualifying completed session. Weeks run Monday-Sunday in the
--     user's stored IANA timezone (public.profiles.timezone); each completed
--     session captures its own IANA timezone so historical day boundaries
--     survive later profile-timezone changes.
--
-- Security: the session timezone is validated defensively against the server's
-- IANA database (pg_timezone_names) at finalization. Only trusted finalization
-- writes routine_sessions.completed_timezone (clients have no UPDATE on that
-- table). Client boundary: the ledger remains read-only; the award is written
-- by the trusted complete_routine_session RPC and surfaced only through the
-- authoritative sync projections and reward_result envelope. RAHA-070 functions
-- use a pg_temp-free SECURITY DEFINER search_path.

-- 1. Versioned ledger. Before RAHA-070 no award rule existed, so any rows that
--    may already exist are marked 'unversioned' rather than falsely attributed
--    to points_completion_v1. The default keeps legacy/manual inserts (which do
--    not yet carry a rule version) non-null; trusted award code always sets it.
alter table public.point_ledger
  add column if not exists rule_version text not null default 'unversioned';
alter table public.point_ledger
  add constraint point_ledger_rule_version_len check (char_length(rule_version) between 1 and 64);

-- 2. Per-session IANA timezone snapshot for historical movement-day boundaries.
alter table public.routine_sessions
  add column if not exists completed_timezone text;

-- 3. Defensive IANA timezone validation against the server's tz database.
create function public.is_valid_iana_timezone(p_zone text)
returns boolean
language sql stable security definer set search_path = public as $$
  select exists (select 1 from pg_catalog.pg_timezone_names where name = p_zone);
$$;

-- Backfill any pre-existing completed sessions defensively; invalid/null stored
-- zones fall back to UTC so the projection never references an unknown zone.
update public.routine_sessions s
set completed_timezone = coalesce(
  (select p.timezone from public.profiles p
    where p.user_id = s.user_id and public.is_valid_iana_timezone(p.timezone)),
  'UTC')
where s.status = 'completed' and (s.completed_timezone is null or s.completed_timezone = '');

-- 4. Trusted, idempotent award. The append-only ledger's partial unique index
--    (user_id, reason_code, source_type, source_id) is the idempotency
--    authority; ON CONFLICT DO NOTHING makes retries and duplicate finalization
--    no-ops. The award is only reachable from a terminal 'completed' session.
create function public.award_completion_points(p_session_id uuid)
returns void
language plpgsql security definer set search_path = public as $$
declare s public.routine_sessions%rowtype;
begin
  select * into s from public.routine_sessions where id = p_session_id;
  if not found or s.user_id <> auth.uid() then raise exception 'session not found'; end if;
  if s.status <> 'completed' then raise exception 'session is not completed'; end if;
  insert into public.point_ledger(user_id, points, reason_code, rule_version, source_type, source_id)
  values (s.user_id, 10, 'routine_completion', 'points_completion_v1', 'session', p_session_id)
  on conflict do nothing;
end $$;

-- 5. Award the point and snapshot the session timezone at terminal completion,
--    regardless of entry path (direct RPC or sync_push session_finalize). The
--    RAHA-022 completion logic is unchanged; only the post-completion award and
--    timezone snapshot are added. The snapshot is the stored profile timezone
--    (validated, falling back to UTC); the sync finalize path may override it
--    with the device-captured zone after this RPC returns.
create or replace function public.complete_routine_session(p_session_id uuid, p_completion_policy_version text)
returns public.session_status
language plpgsql security definer set search_path = public as $$
declare session_row public.routine_sessions%rowtype; expected_steps integer; recorded_steps integer; credited_seconds integer; completed_count integer; partial_count integer; skipped_count integer; outcome public.session_status; v_timezone text;
begin
  select * into session_row from public.routine_sessions where id = p_session_id for update;
  if not found or session_row.user_id <> auth.uid() then raise exception 'session not found'; end if;
  if session_row.status <> 'in_progress' then raise exception 'session is terminal'; end if;
  if p_completion_policy_version <> 'raha_001_v1' then raise exception 'unsupported completion policy'; end if;
  select count(*) into expected_steps from public.routine_steps where routine_id = session_row.routine_id;
  select count(*), coalesce(sum(least(ss.active_duration_seconds, ss.target_duration_seconds)), 0), count(*) filter (where ss.status = 'completed'), count(*) filter (where ss.status = 'partial'), count(*) filter (where ss.status = 'skipped') into recorded_steps, credited_seconds, completed_count, partial_count, skipped_count from public.session_steps ss join public.routine_steps rs on rs.id = ss.routine_step_id where ss.session_id = p_session_id and rs.routine_id = session_row.routine_id and rs.exercise_id = ss.exercise_id_snapshot and rs.position = ss.position_snapshot and ss.target_duration_seconds = rs.duration_seconds;
  if recorded_steps <> expected_steps or recorded_steps <> (select count(*) from public.session_steps where session_id = p_session_id) then raise exception 'session steps do not match routine'; end if;
  select case when credited_seconds >= r.estimated_duration_seconds * 0.80 and skipped_count <= floor(expected_steps * 0.20) and completed_count + partial_count + skipped_count = expected_steps then 'completed'::public.session_status else 'abandoned'::public.session_status end into outcome from public.routines r where r.id = session_row.routine_id;
  update public.routine_sessions set status = outcome, completed_at = now(), target_duration_seconds = (select estimated_duration_seconds from public.routines where id = session_row.routine_id), actual_duration_seconds = least(credited_seconds, (select estimated_duration_seconds from public.routines where id = session_row.routine_id)), total_step_count_snapshot = expected_steps, steps_completed = completed_count, steps_partial = partial_count, steps_skipped = skipped_count, completion_policy_version = p_completion_policy_version where id = p_session_id;
  if outcome = 'completed' then
    select case when public.is_valid_iana_timezone(p.timezone) then p.timezone else 'UTC' end into v_timezone
    from public.profiles p where p.user_id = session_row.user_id;
    update public.routine_sessions set completed_timezone = v_timezone where id = p_session_id;
    perform public.award_completion_points(p_session_id);
  end if;
  return outcome;
end $$;

-- 6. Accept and defensively validate the device-captured timezone in the
--    session_finalize payload. The field is optional (backward compatible):
--    absent/empty means the server snapshot (profile timezone) is authoritative.
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
  else raise exception 'unsupported sync operation kind'; end if;
end $$;

-- 7. Apply the device-captured timezone (already validated) when finalizing via
--    sync. The award and reward_result are otherwise unchanged.
create or replace function public.sync_push_user_data(p_operations jsonb)
returns jsonb language plpgsql security definer set search_path = public as $$
declare
  op jsonb; op_id uuid; op_hash text; kind text; body jsonb; result jsonb := '[]'::jsonb; operation_result jsonb;
  v_session_id uuid; v_routine_id uuid; v_routine_step_id uuid; entity_id uuid; incoming_operation_at timestamptz;
  current_saved public.saved_routines%rowtype; final_status public.session_status; body_area_ids uuid[]; canonical_check_in jsonb;
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
    end if;
    insert into public.sync_applied_operations(user_id,operation_id,request_hash,response) values (auth.uid(),op_id,op_hash,operation_result);
    result := result || jsonb_build_array(operation_result);
  end loop;
  return jsonb_build_object('operations',result,'cursor',(select coalesce(max(cursor),0) from public.user_sync_changes where user_id=auth.uid()),'projections',public.sync_authoritative_projections(auth.uid()));
end $$;

-- 8. movement_day_v1 weekly projection. The reference week is the Monday-Sunday
--    window derived from p_at (default now()) in the user's stored timezone.
--    Each completed session's local movement date AND its Monday week identity
--    are both derived in that session's captured timezone (falling back to the
--    stored timezone), so a session whose local day falls in a different week
--    (e.g. Sunday in Honolulu while the stored timezone is already Monday in
--    Riyadh) is not counted against the current reference week. Distinct dates
--    collapse same-day sessions; only completed sessions count.
create or replace function public.weekly_movement_progress(p_user_id uuid, p_at timestamptz default now())
returns jsonb
language sql stable security definer set search_path = public as $$
  with ref as (
    select case when public.is_valid_iana_timezone(p.timezone) then p.timezone else 'UTC' end as tz,
           p.weekly_goal_days,
           (p_at at time zone case when public.is_valid_iana_timezone(p.timezone) then p.timezone else 'UTC' end)::date as ref_day
    from public.profiles p
    where p.user_id = p_user_id
  ), week as (
    select tz, weekly_goal_days,
           ref_day - (extract(isodow from ref_day)::integer - 1) as monday,
           ((ref_day - (extract(isodow from ref_day)::integer - 1))::timestamp) at time zone tz as week_start,
           ((ref_day - (extract(isodow from ref_day)::integer - 1) + 7)::timestamp) at time zone tz as week_end
    from ref
  ), days as (
    select distinct d
    from (
      select (s.completed_at at time zone
        case when public.is_valid_iana_timezone(s.completed_timezone) then s.completed_timezone else w.tz end)::date as d,
        w.monday
      from public.routine_sessions s, week w
      where s.user_id = p_user_id and s.status = 'completed'
    ) x
    where d - (extract(isodow from d)::integer - 1) = monday
  )
  select jsonb_build_object(
    'rule_version', 'movement_day_v1',
    'timezone', w.tz,
    'goal_days', w.weekly_goal_days,
    'week_start', w.week_start,
    'week_end', w.week_end,
    'movement_days', (select count(*) from days),
    'movement_dates', (select coalesce(jsonb_agg(d order by d), '[]'::jsonb) from days)
  )
  from week w;
$$;

-- 9. Extend the authoritative projection: expose each award's rule_version, the
--    running points balance, and the weekly movement-day projection. No PII or
--    free text is emitted.
create or replace function public.sync_authoritative_projections(p_user_id uuid)
returns jsonb language sql stable security definer set search_path = public as $$
  select jsonb_build_object(
    'points', coalesce((select jsonb_agg(jsonb_build_object('id',id,'points',points,'reason_code',reason_code,'rule_version',rule_version,'source_type',source_type,'source_id',source_id,'created_at',created_at) order by created_at,id) from public.point_ledger where user_id=p_user_id), '[]'::jsonb),
    'points_balance', coalesce((select sum(points)::integer from public.point_ledger where user_id=p_user_id), 0),
    'weekly_progress', public.weekly_movement_progress(p_user_id),
    'achievements', coalesce((select jsonb_agg(jsonb_build_object('achievement_id',achievement_id,'earned_at',earned_at,'source_id',source_id,'criteria_version',criteria_version) order by earned_at,achievement_id) from public.user_achievements where user_id=p_user_id), '[]'::jsonb),
    'streak', (select jsonb_build_object('current_streak_days',current_streak_days,'longest_streak_days',longest_streak_days,'last_movement_date',last_movement_date,'rule_version',rule_version,'updated_at',updated_at) from public.user_streaks where user_id=p_user_id),
    'entitlements', coalesce((select jsonb_agg(jsonb_build_object('entitlement_key',entitlement_key,'is_active',is_active,'product_id',product_id,'expires_at',expires_at,'environment',environment,'updated_at',updated_at) order by entitlement_key) from public.user_entitlements where user_id=p_user_id), '[]'::jsonb)
  )
$$;

-- 10. reward_result is an idempotent response envelope; it now carries the rule
--     version of each award alongside the existing fields. Version stays
--     'raha_025_reward_result_v1' because the change is additive.
create or replace function public.sync_reward_result(p_user_id uuid, p_session_id uuid, p_final_status public.session_status)
returns jsonb language sql stable security definer set search_path = public as $$
  select jsonb_build_object(
    'version', 'raha_025_reward_result_v1',
    'session_id', p_session_id,
    'final_status', p_final_status,
    'awards', jsonb_build_object(
      'points', case when p_final_status = 'completed' then coalesce((
        select jsonb_agg(jsonb_build_object('id', id, 'points', points, 'reason_code', reason_code, 'rule_version', rule_version, 'created_at', created_at) order by created_at, id)
        from public.point_ledger
        where user_id = p_user_id and source_type = 'session' and source_id = p_session_id
      ), '[]'::jsonb) else '[]'::jsonb end,
      'achievements', case when p_final_status = 'completed' then coalesce((
        select jsonb_agg(jsonb_build_object('achievement_id', achievement_id, 'earned_at', earned_at, 'criteria_version', criteria_version) order by earned_at, achievement_id)
        from public.user_achievements
        where user_id = p_user_id and source_id = p_session_id
      ), '[]'::jsonb) else '[]'::jsonb end
    )
  )
$$;

-- 11. Trusted-only ACL. The award, validation, and projection helpers are not
--     client-callable; clients receive these results only through sync_push/pull.
revoke all on function public.is_valid_iana_timezone(text) from public, anon, authenticated;
revoke all on function public.award_completion_points(uuid) from public, anon, authenticated;
revoke all on function public.weekly_movement_progress(uuid, timestamptz) from public, anon, authenticated;
revoke all on function public.sync_authoritative_projections(uuid) from public, anon, authenticated;
revoke all on function public.sync_reward_result(uuid, uuid, public.session_status) from public, anon, authenticated;
