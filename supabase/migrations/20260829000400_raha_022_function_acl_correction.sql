-- RAHA-022: Supabase default function privileges can be granted directly to
-- anon/authenticated, so revoking only from PUBLIC is insufficient.
revoke all on function public.semver_parts(text) from public, anon, authenticated;
revoke all on function public.release_is_available(bigint, text) from public, anon, authenticated;
revoke all on function public.record_session_credit_activity() from public, anon, authenticated;
revoke all on function public.get_next_free_content_release(bigint, text) from public, anon, authenticated;
revoke all on function public.start_routine_session(uuid, uuid, integer, uuid, text, text) from public, anon, authenticated;
revoke all on function public.complete_routine_session(uuid, text) from public, anon, authenticated;
revoke all on function public.expire_my_stale_routine_sessions() from public, anon, authenticated;
revoke all on function public.expire_stale_routine_sessions() from public, anon, authenticated;

grant execute on function public.get_next_free_content_release(bigint, text) to anon, authenticated;
grant execute on function public.start_routine_session(uuid, uuid, integer, uuid, text, text) to authenticated;
grant execute on function public.complete_routine_session(uuid, text) to authenticated;
grant execute on function public.expire_my_stale_routine_sessions() to authenticated;
grant execute on function public.expire_stale_routine_sessions() to service_role;
