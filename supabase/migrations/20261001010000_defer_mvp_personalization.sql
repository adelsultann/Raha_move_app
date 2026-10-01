-- Defer preference-driven check-ins and recommendations from the simplified
-- MVP while retaining the shared tables required for migration compatibility.
--
-- Profile settings still use preference_upsert for language, sound, vibration,
-- downloads, and privacy consent. Only check-in and recommendation writes are
-- rejected. A later release must restore these operations through a new
-- forward migration after product review.

alter function public.sync_validate_push_operation(jsonb)
rename to sync_validate_push_operation_before_mvp_deferral;

create function public.sync_validate_push_operation(p_operation jsonb)
returns void
language plpgsql stable security definer set search_path = public as $$
declare
  operation_kind text := p_operation->>'kind';
begin
  if operation_kind in ('check_in_upsert', 'recommendation_upsert') then
    raise exception 'feature deferred from simplified MVP';
  end if;

  perform public.sync_validate_push_operation_before_mvp_deferral(p_operation);
end $$;

revoke all on function
  public.sync_validate_push_operation_before_mvp_deferral(jsonb)
from public, anon, authenticated;
revoke all on function public.sync_validate_push_operation(jsonb)
from public, anon, authenticated;

-- Mobile clients use the trusted sync function. Remove the legacy direct-write
-- path as a second boundary while these features are absent from the app.
revoke insert, update, delete on table
  public.user_preferred_positions,
  public.user_avoided_exercises,
  public.user_body_area_preferences,
  public.check_ins,
  public.check_in_body_areas,
  public.recommendations
from authenticated;

comment on table public.user_preferred_positions is
  'Dormant movement-preference storage retained for post-MVP compatibility.';
comment on table public.user_avoided_exercises is
  'Dormant movement-preference storage retained for post-MVP compatibility.';
comment on table public.user_body_area_preferences is
  'Dormant movement-preference storage retained for post-MVP compatibility.';
comment on table public.check_ins is
  'Dormant check-in storage retained for post-MVP compatibility.';
comment on table public.check_in_body_areas is
  'Dormant check-in storage retained for post-MVP compatibility.';
comment on table public.recommendations is
  'Dormant recommendation storage retained for post-MVP compatibility.';
