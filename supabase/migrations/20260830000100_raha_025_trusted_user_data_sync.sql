-- RAHA-025: forward-only trusted user-data synchronization contract.
-- The mobile client submits stable UUID operation IDs.  These tables are
-- intentionally not exposed through PostgREST; authenticated clients use only
-- the two RPCs below.

alter table public.saved_routines
  add column if not exists operation_at timestamptz;
update public.saved_routines
  set operation_at = coalesce(updated_at, created_at, now())
  where operation_at is null;
alter table public.saved_routines
  alter column operation_at set not null;
create index if not exists saved_routines_owner_operation_cursor
  on public.saved_routines(user_id, operation_at, routine_id);

create table public.sync_applied_operations (
  user_id uuid not null references public.profiles(user_id) on delete cascade,
  operation_id uuid not null,
  request_hash text not null check (request_hash ~ '^[0-9a-f]{64}$'),
  applied_at timestamptz not null default now(),
  primary key (user_id, operation_id)
);

create table public.user_sync_changes (
  cursor bigint generated always as identity primary key,
  user_id uuid not null references public.profiles(user_id) on delete cascade,
  entity_type text not null check (entity_type in ('check_in','recommendation','session','session_step','feedback','saved_routine')),
  entity_id uuid not null,
  operation text not null check (operation in ('upsert','delete','finalize')),
  payload jsonb not null,
  occurred_at timestamptz not null default now(),
  created_at timestamptz not null default now()
);
create index user_sync_changes_owner_cursor on public.user_sync_changes(user_id, cursor);
alter table public.sync_applied_operations enable row level security;
alter table public.user_sync_changes enable row level security;

create function public.sync_authoritative_projections(p_user_id uuid)
returns jsonb language sql stable security definer set search_path = public, pg_temp as $$
  select jsonb_build_object(
    'points', coalesce((select jsonb_agg(jsonb_build_object('id',id,'points',points,'reason_code',reason_code,'source_type',source_type,'source_id',source_id,'created_at',created_at) order by created_at,id) from public.point_ledger where user_id=p_user_id), '[]'::jsonb),
    'achievements', coalesce((select jsonb_agg(jsonb_build_object('achievement_id',achievement_id,'earned_at',earned_at,'source_id',source_id,'criteria_version',criteria_version) order by earned_at,achievement_id) from public.user_achievements where user_id=p_user_id), '[]'::jsonb),
    'streak', (select jsonb_build_object('current_streak_days',current_streak_days,'longest_streak_days',longest_streak_days,'last_movement_date',last_movement_date,'rule_version',rule_version,'updated_at',updated_at) from public.user_streaks where user_id=p_user_id),
    'entitlements', coalesce((select jsonb_agg(jsonb_build_object('entitlement_key',entitlement_key,'is_active',is_active,'product_id',product_id,'expires_at',expires_at,'environment',environment,'updated_at',updated_at) order by entitlement_key) from public.user_entitlements where user_id=p_user_id), '[]'::jsonb)
  )
$$;

create function public.record_user_sync_change(p_entity_type text, p_entity_id uuid, p_operation text, p_payload jsonb)
returns void language sql volatile security definer set search_path = public, pg_temp as $$
  insert into public.user_sync_changes(user_id,entity_type,entity_id,operation,payload)
  values (auth.uid(),p_entity_type,p_entity_id,p_operation,p_payload)
$$;

create function public.sync_push_user_data(p_operations jsonb)
returns jsonb language plpgsql security definer set search_path = public, pg_temp as $$
declare
  op jsonb; op_id uuid; op_hash text; kind text; body jsonb; result jsonb := '[]'::jsonb;
  v_session_id uuid; v_routine_id uuid; v_routine_step_id uuid; entity_id uuid; incoming_operation_at timestamptz;
  current_saved public.saved_routines%rowtype; final_status public.session_status;
begin
  if auth.uid() is null then raise exception 'authentication required'; end if;
  if jsonb_typeof(p_operations) <> 'array' or jsonb_array_length(p_operations) > 100 then
    raise exception 'operations must be an array of at most 100 items';
  end if;
  for op in select value from jsonb_array_elements(p_operations) loop
    begin
      op_id := (op->>'operation_id')::uuid;
      kind := op->>'kind'; body := coalesce(op->'payload','{}'::jsonb);
    exception when others then raise exception 'operation_id and payload are required'; end;
    op_hash := encode(extensions.digest(convert_to(op::text,'UTF8'),'sha256'),'hex');
    if exists (select 1 from public.sync_applied_operations x where x.user_id=auth.uid() and x.operation_id=op_id) then
      if not exists (select 1 from public.sync_applied_operations x where x.user_id=auth.uid() and x.operation_id=op_id and x.request_hash=op_hash) then raise exception 'operation_id was reused with different content'; end if;
      result := result || jsonb_build_array(jsonb_build_object('operation_id',op_id,'status','replayed'));
      continue;
    end if;

    if kind = 'check_in_upsert' then
      entity_id := (body->>'id')::uuid;
      insert into public.check_ins(id,user_id,body_state,goal_id,available_minutes,position_id,started_at,completed_at)
      values (entity_id,auth.uid(),body->>'body_state',(body->>'goal_id')::uuid,(body->>'available_minutes')::smallint,nullif(body->>'position_id','')::uuid,(body->>'started_at')::timestamptz,nullif(body->>'completed_at','')::timestamptz)
      on conflict (id) do update set completed_at=coalesce(excluded.completed_at,public.check_ins.completed_at), body_state=excluded.body_state, goal_id=excluded.goal_id, available_minutes=excluded.available_minutes, position_id=excluded.position_id
      where public.check_ins.user_id=auth.uid();
      if not found then raise exception 'check-in id belongs to another user'; end if;
      perform public.record_user_sync_change('check_in',entity_id,'upsert',body);
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
      entity_id := (body->>'id')::uuid;
      perform public.start_routine_session(entity_id,(body->>'routine_id')::uuid,(body->>'routine_version')::integer,nullif(body->>'recommendation_id','')::uuid,body->>'source',body->>'app_version');
      perform public.record_user_sync_change('session',entity_id,'upsert',jsonb_build_object('id',entity_id));
    elsif kind = 'session_step_upsert' then
      v_session_id := (body->>'session_id')::uuid; v_routine_step_id := (body->>'routine_step_id')::uuid;
      if not exists(select 1 from public.routine_sessions where id=v_session_id and user_id=auth.uid() and status='in_progress') then raise exception 'session is missing or terminal'; end if;
      if not public.can_write_own_session_step(v_session_id,v_routine_step_id,(body->>'exercise_id_snapshot')::uuid,(body->>'position_snapshot')::smallint,(body->>'target_duration_seconds')::integer) then raise exception 'session step does not match the session routine'; end if;
      insert into public.session_steps(session_id,routine_step_id,exercise_id_snapshot,position_snapshot,status,target_duration_seconds,active_duration_seconds,skip_requested,started_at,finished_at)
      values (v_session_id,v_routine_step_id,(body->>'exercise_id_snapshot')::uuid,(body->>'position_snapshot')::smallint,(body->>'status')::public.step_status,(body->>'target_duration_seconds')::integer,(body->>'active_duration_seconds')::integer,coalesce((body->>'skip_requested')::boolean,false),nullif(body->>'started_at','')::timestamptz,nullif(body->>'finished_at','')::timestamptz)
      on conflict (session_id,routine_step_id) do update set status=excluded.status, active_duration_seconds=greatest(public.session_steps.active_duration_seconds,excluded.active_duration_seconds), skip_requested=public.session_steps.skip_requested or excluded.skip_requested, started_at=coalesce(public.session_steps.started_at,excluded.started_at), finished_at=coalesce(excluded.finished_at,public.session_steps.finished_at)
      where public.session_steps.status='pending' or public.session_steps.active_duration_seconds <= excluded.active_duration_seconds;
      if not found then raise exception 'session step conflicts with terminal progress'; end if;
      perform public.record_user_sync_change('session_step',v_session_id,'upsert',body);
    elsif kind = 'session_finalize' then
      entity_id := (body->>'session_id')::uuid;
      final_status := public.complete_routine_session(entity_id,body->>'completion_policy_version');
      perform public.record_user_sync_change('session',entity_id,'finalize',jsonb_build_object('id',entity_id,'status',final_status));
    elsif kind = 'feedback_upsert' then
      entity_id := (body->>'session_id')::uuid;
      if not exists(select 1 from public.routine_sessions where id=entity_id and user_id=auth.uid() and status='completed') then raise exception 'feedback requires a completed session'; end if;
      insert into public.session_feedback(session_id,user_id,rating,uncomfortable_exercise_id,note,created_at)
      values (entity_id,auth.uid(),(body->>'rating')::public.feedback_rating,nullif(body->>'uncomfortable_exercise_id','')::uuid,nullif(body->>'note',''),coalesce(nullif(body->>'created_at','')::timestamptz,now()))
      on conflict (session_id) do update set rating=excluded.rating, uncomfortable_exercise_id=excluded.uncomfortable_exercise_id, note=excluded.note
      where public.session_feedback.user_id=auth.uid();
      if not found then raise exception 'feedback belongs to another user'; end if;
      perform public.record_user_sync_change('feedback',entity_id,'upsert',body - 'note');
    elsif kind = 'saved_routine_set' then
      v_routine_id := (body->>'routine_id')::uuid; incoming_operation_at := (body->>'operation_at')::timestamptz;
      if not exists(select 1 from public.routines where id=v_routine_id and status='published' and access_tier='free' and published_at<=now()) then raise exception 'routine is unavailable'; end if;
      select * into current_saved from public.saved_routines where user_id=auth.uid() and routine_id=v_routine_id for update;
      if not found then
        insert into public.saved_routines(user_id,routine_id,created_at,updated_at,deleted_at,operation_at) values (auth.uid(),v_routine_id,incoming_operation_at,incoming_operation_at,case when coalesce((body->>'saved')::boolean,false) then null else incoming_operation_at end,incoming_operation_at);
      elsif incoming_operation_at > current_saved.operation_at or (incoming_operation_at = current_saved.operation_at and current_saved.deleted_at is null and not coalesce((body->>'saved')::boolean,false)) then
        update public.saved_routines set deleted_at=case when coalesce((body->>'saved')::boolean,false) then null else incoming_operation_at end, operation_at=incoming_operation_at where user_id=auth.uid() and routine_id=v_routine_id;
      end if;
      -- Return the persisted winner, not the stale request. This makes an old
      -- save operation unable to resurrect a newer tombstone during pull.
      perform public.record_user_sync_change('saved_routine',v_routine_id,
        (select case when deleted_at is null then 'upsert' else 'delete' end from public.saved_routines where user_id=auth.uid() and routine_id=v_routine_id),
        (select jsonb_build_object('routine_id',routine_id,'saved',deleted_at is null,'operation_at',operation_at) from public.saved_routines where user_id=auth.uid() and routine_id=v_routine_id));
    else raise exception 'unsupported sync operation kind';
    end if;
    insert into public.sync_applied_operations(user_id,operation_id,request_hash) values (auth.uid(),op_id,op_hash);
    result := result || jsonb_build_array(jsonb_build_object('operation_id',op_id,'status','applied'));
  end loop;
  return jsonb_build_object('operations',result,'cursor',(select coalesce(max(cursor),0) from public.user_sync_changes where user_id=auth.uid()),'projections',public.sync_authoritative_projections(auth.uid()));
end $$;

create function public.sync_pull_user_data(p_after_cursor bigint default 0, p_limit integer default 100)
returns jsonb language plpgsql stable security definer set search_path = public, pg_temp as $$
declare bounded_limit integer;
begin
  if auth.uid() is null then raise exception 'authentication required'; end if;
  bounded_limit := greatest(1,least(coalesce(p_limit,100),500));
  return jsonb_build_object(
    'changes',coalesce((select jsonb_agg(jsonb_build_object('cursor',cursor,'entity_type',entity_type,'entity_id',entity_id,'operation',operation,'payload',payload,'occurred_at',occurred_at) order by cursor) from (select * from public.user_sync_changes where user_id=auth.uid() and cursor>coalesce(p_after_cursor,0) order by cursor limit bounded_limit) c),'[]'::jsonb),
    'cursor',(select coalesce(max(cursor),coalesce(p_after_cursor,0)) from (select cursor from public.user_sync_changes where user_id=auth.uid() and cursor>coalesce(p_after_cursor,0) order by cursor limit bounded_limit) c),
    'projections',public.sync_authoritative_projections(auth.uid())
  );
end $$;

revoke all on table public.sync_applied_operations, public.user_sync_changes from public, anon, authenticated;
revoke all on function public.sync_authoritative_projections(uuid), public.record_user_sync_change(text,uuid,text,jsonb), public.sync_push_user_data(jsonb), public.sync_pull_user_data(bigint,integer) from public, anon, authenticated;
grant execute on function public.sync_push_user_data(jsonb), public.sync_pull_user_data(bigint,integer) to authenticated;
