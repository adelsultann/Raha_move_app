-- The policy predicate is intentionally the only client-callable trusted
-- helper; it returns only a boolean for the caller's own in-progress session.
grant execute on function public.can_write_own_session_step(uuid, uuid, uuid, smallint, integer) to authenticated;
