-- RAHA-022 final API ACL allowlist. Run as postgres only after every migration.
-- This is an operator/CI deployment gate, not a client authorization test.
do $$
declare unexpected text;
begin
  if not has_schema_privilege('anon', 'public', 'usage')
     or not has_schema_privilege('authenticated', 'public', 'usage') then
    raise exception 'API role lacks required USAGE on public';
  end if;
  if has_schema_privilege('anon', 'public', 'create')
     or has_schema_privilege('authenticated', 'public', 'create')
     or has_schema_privilege('public', 'public', 'create') then
    raise exception 'API role or PUBLIC can CREATE in public';
  end if;

  select string_agg(grantee || ':' || table_name || ':' || privilege_type, ', ' order by 1)
  into unexpected
  from information_schema.role_table_grants
  where table_schema = 'public' and grantee in ('PUBLIC', 'anon', 'authenticated')
    and (grantee <> 'authenticated' or (table_name, privilege_type) not in (
      ('profiles','SELECT'),('profiles','INSERT'),('profiles','UPDATE'),
      ('user_preferences','SELECT'),('user_preferences','INSERT'),('user_preferences','UPDATE'),('user_preferences','DELETE'),
      ('reminder_schedules','SELECT'),('reminder_schedules','INSERT'),('reminder_schedules','UPDATE'),('reminder_schedules','DELETE'),
      ('user_preferred_positions','SELECT'),('user_preferred_positions','INSERT'),('user_preferred_positions','UPDATE'),('user_preferred_positions','DELETE'),
      ('user_avoided_exercises','SELECT'),('user_avoided_exercises','INSERT'),('user_avoided_exercises','UPDATE'),('user_avoided_exercises','DELETE'),
      ('user_body_area_preferences','SELECT'),('user_body_area_preferences','INSERT'),('user_body_area_preferences','UPDATE'),('user_body_area_preferences','DELETE'),
      ('check_ins','SELECT'),('check_ins','INSERT'),('check_ins','UPDATE'),('check_ins','DELETE'),
      ('check_in_body_areas','SELECT'),('check_in_body_areas','INSERT'),('check_in_body_areas','UPDATE'),('check_in_body_areas','DELETE'),
      ('recommendations','SELECT'),('recommendations','INSERT'),('recommendations','UPDATE'),('recommendations','DELETE'),
      ('routine_sessions','SELECT'),('routine_sessions','UPDATE'),('routine_sessions','DELETE'),
      ('session_steps','SELECT'),('session_steps','INSERT'),('session_steps','UPDATE'),('session_steps','DELETE'),
      ('session_feedback','SELECT'),('session_feedback','INSERT'),('session_feedback','UPDATE'),('session_feedback','DELETE'),
      ('saved_routines','SELECT'),('saved_routines','INSERT'),('saved_routines','UPDATE'),('saved_routines','DELETE'),
      ('point_ledger','SELECT'),('user_achievements','SELECT'),('user_streaks','SELECT'),('user_entitlements','SELECT'),
      ('mobile_session_feedback','SELECT')
    ));
  if unexpected is not null then raise exception 'unexpected public relation grant(s): %', unexpected; end if;

  if has_function_privilege('anon','public.get_next_free_content_release(bigint,text)','execute') is false
     or has_function_privilege('authenticated','public.get_next_free_content_release(bigint,text)','execute') is false
     or has_function_privilege('authenticated','public.start_routine_session(uuid,uuid,integer,uuid,text,text)','execute') is false
     or has_function_privilege('authenticated','public.complete_routine_session(uuid,text)','execute') is false
     or has_function_privilege('authenticated','public.expire_my_stale_routine_sessions()','execute') is false
     or has_function_privilege('authenticated','public.can_write_own_session_step(uuid,uuid,uuid,smallint,integer)','execute') is false then
    raise exception 'required client RPC execute grant missing';
  end if;
  if has_function_privilege('anon','public.start_routine_session(uuid,uuid,integer,uuid,text,text)','execute')
     or has_function_privilege('anon','public.complete_routine_session(uuid,text)','execute')
     or has_function_privilege('anon','public.expire_stale_routine_sessions()','execute')
     or has_function_privilege('authenticated','public.expire_stale_routine_sessions()','execute')
     or has_function_privilege('anon','public.semver_parts(text)','execute')
     or has_function_privilege('authenticated','public.release_is_available(bigint,text)','execute') then
    raise exception 'forbidden RPC execute grant present';
  end if;
end $$;
