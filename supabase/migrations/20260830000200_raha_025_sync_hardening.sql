-- RAHA-025 security hardening (forward only).
-- Bounded device-reported time is the approved RAHA-001 offline model: it is
-- input, not attestation. A step's target is matched to its routine-bound
-- server value, active seconds are rejected above that value, and the existing
-- complete_routine_session RPC derives/caps session aggregates from those
-- validated rows. No client aggregate duration is accepted by this contract.
--
-- sync_applied_operations is a retry diagnostic/idempotency record and is
-- retained for 30 days. user_sync_changes is a private owner change feed, not
-- an API diagnostic log; both tables cascade when the profile/account is
-- deleted, with no orphaned sync data.

alter function public.sync_push_user_data(jsonb) rename to sync_push_user_data_unvalidated;
revoke all on function public.sync_push_user_data_unvalidated(jsonb) from public, anon, authenticated;

create function public.sync_validate_object_fields(p_value jsonb, p_allowed text[], p_required text[], p_label text)
returns void language plpgsql immutable set search_path = public, pg_temp as $$
declare bad_key text; required_key text;
begin
  if jsonb_typeof(p_value) <> 'object' then raise exception '% must be an object', p_label; end if;
  select key into bad_key from jsonb_object_keys(p_value) key where not key = any(p_allowed) limit 1;
  if bad_key is not null then raise exception '% contains unknown field %', p_label, bad_key; end if;
  foreach required_key in array p_required loop
    if not p_value ? required_key or p_value->required_key is null then raise exception '% is missing required field %', p_label, required_key; end if;
  end loop;
end $$;

create function public.sync_validate_string(p_value jsonb, p_key text, p_max_bytes integer, p_required boolean default false)
returns void language plpgsql immutable set search_path = public, pg_temp as $$
begin
  if not p_value ? p_key then if p_required then raise exception 'payload is missing required field %', p_key; else return; end if; end if;
  if jsonb_typeof(p_value->p_key) <> 'string' or octet_length(p_value->>p_key) = 0 or octet_length(p_value->>p_key) > p_max_bytes then
    raise exception '% must be a non-empty string of at most % bytes', p_key, p_max_bytes;
  end if;
  if p_key in ('id','operation_id','goal_id','position_id','check_in_id','routine_id','recommendation_id','session_id','routine_step_id','exercise_id_snapshot','uncomfortable_exercise_id')
     and p_value->>p_key !~* '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$' then
    raise exception '% must be a UUID', p_key;
  end if;
end $$;

create function public.sync_validate_integer(p_value jsonb, p_key text, p_min integer, p_max integer)
returns integer language plpgsql immutable set search_path = public, pg_temp as $$
declare value_text text; value_integer integer;
begin
  if jsonb_typeof(p_value->p_key) <> 'number' then raise exception '% must be an integer', p_key; end if;
  value_text := p_value->>p_key;
  if value_text !~ '^-?[0-9]{1,9}$' then raise exception '% must be an integer', p_key; end if;
  value_integer := value_text::integer;
  if value_integer < p_min or value_integer > p_max then raise exception '% must be between % and %', p_key, p_min, p_max; end if;
  return value_integer;
end $$;

create function public.sync_validate_push_operation(p_operation jsonb)
returns void language plpgsql stable security definer set search_path = public, pg_temp as $$
declare kind text := p_operation->>'kind'; body jsonb := p_operation->'payload'; active_seconds integer; target_seconds integer; reason text;
begin
  perform public.sync_validate_object_fields(p_operation,array['operation_id','kind','payload'],array['operation_id','kind','payload'],'operation');
  perform public.sync_validate_string(p_operation,'operation_id',36,true);
  perform public.sync_validate_string(p_operation,'kind',32,true);
  if (p_operation->>'operation_id') !~* '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$' then raise exception 'operation_id must be a UUID'; end if;
  if kind = 'check_in_upsert' then
    perform public.sync_validate_object_fields(body,array['id','body_state','goal_id','available_minutes','position_id','started_at','completed_at'],array['id','body_state','goal_id','available_minutes','started_at'],'check_in_upsert payload');
    perform public.sync_validate_string(body,'id',36,true); perform public.sync_validate_string(body,'body_state',16,true); perform public.sync_validate_string(body,'goal_id',36,true); perform public.sync_validate_string(body,'started_at',64,true); perform public.sync_validate_string(body,'position_id',36); perform public.sync_validate_string(body,'completed_at',64); perform public.sync_validate_integer(body,'available_minutes',3,15);
    if body->>'body_state' not in ('comfortable','stiff','tired','tense') or (body->>'available_minutes')::integer not in (3,5,10,15) then raise exception 'invalid check-in value'; end if;
  elsif kind = 'recommendation_upsert' then
    perform public.sync_validate_object_fields(body,array['id','check_in_id','routine_id','engine_version','rank','score','reason_codes','shown_at','accepted_at','rejected_at','rejection_reason'],array['id','check_in_id','routine_id','engine_version','rank','score','reason_codes','shown_at'],'recommendation_upsert payload');
    perform public.sync_validate_string(body,'id',36,true); perform public.sync_validate_string(body,'check_in_id',36,true); perform public.sync_validate_string(body,'routine_id',36,true); perform public.sync_validate_string(body,'engine_version',64,true); perform public.sync_validate_string(body,'shown_at',64,true); perform public.sync_validate_string(body,'accepted_at',64); perform public.sync_validate_string(body,'rejected_at',64); perform public.sync_validate_string(body,'rejection_reason',16); perform public.sync_validate_integer(body,'rank',1,100); perform public.sync_validate_integer(body,'score',-1000000,1000000);
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
    perform public.sync_validate_object_fields(body,array['session_id','completion_policy_version'],array['session_id','completion_policy_version'],'session_finalize payload');
    perform public.sync_validate_string(body,'session_id',36,true); perform public.sync_validate_string(body,'completion_policy_version',64,true);
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

create or replace function public.record_user_sync_change(p_entity_type text, p_entity_id uuid, p_operation text, p_payload jsonb)
returns void language plpgsql volatile security definer set search_path = public, pg_temp as $$
declare canonical jsonb;
begin
  -- The wrapper validates every field before the unvalidated compatibility
  -- implementation runs. Rebuild the logged document to prevent arbitrary
  -- request keys or feedback notes entering the pull feed.
  canonical := case p_entity_type
    when 'session' then jsonb_build_object('id',p_payload->'id','status',p_payload->'status')
    when 'feedback' then jsonb_build_object('session_id',p_payload->'session_id','rating',p_payload->'rating','uncomfortable_exercise_id',p_payload->'uncomfortable_exercise_id','created_at',p_payload->'created_at')
    else jsonb_strip_nulls(p_payload)
  end;
  insert into public.user_sync_changes(user_id,entity_type,entity_id,operation,payload) values (auth.uid(),p_entity_type,p_entity_id,p_operation,canonical);
end $$;

create function public.sync_push_user_data(p_operations jsonb)
returns jsonb language plpgsql security definer set search_path = public, pg_temp as $$
declare op jsonb;
begin
  if auth.uid() is null then raise exception 'authentication required'; end if;
  if jsonb_typeof(p_operations) <> 'array' or jsonb_array_length(p_operations) > 100 or octet_length(p_operations::text) > 262144 then raise exception 'operations must be an array of at most 100 items and 262144 bytes'; end if;
  for op in select value from jsonb_array_elements(p_operations) loop
    if octet_length(op::text) > 8192 then raise exception 'operation exceeds 8192 bytes'; end if;
    perform public.sync_validate_push_operation(op);
  end loop;
  return public.sync_push_user_data_unvalidated(p_operations);
end $$;

create function public.purge_expired_sync_diagnostics(p_before timestamptz default now() - interval '30 days')
returns bigint language plpgsql security definer set search_path = public, pg_temp as $$
declare removed bigint;
begin
  if p_before > now() - interval '30 days' then raise exception 'sync diagnostics must be retained for at least 30 days'; end if;
  delete from public.sync_applied_operations where applied_at < p_before;
  get diagnostics removed = row_count;
  return removed;
end $$;

revoke all on function public.sync_validate_object_fields(jsonb,text[],text[],text), public.sync_validate_string(jsonb,text,integer,boolean), public.sync_validate_integer(jsonb,text,integer,integer), public.sync_validate_push_operation(jsonb), public.record_user_sync_change(text,uuid,text,jsonb), public.sync_push_user_data_unvalidated(jsonb), public.sync_push_user_data(jsonb), public.purge_expired_sync_diagnostics(timestamptz) from public, anon, authenticated;
grant execute on function public.sync_push_user_data(jsonb) to authenticated;
grant execute on function public.purge_expired_sync_diagnostics(timestamptz) to service_role;
