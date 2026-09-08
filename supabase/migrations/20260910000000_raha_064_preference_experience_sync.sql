-- RAHA-064 preference-sync remediation (forward only).
--
-- `experience_level` already has an enum-backed server column. This migration
-- adds it as an OPTIONAL preferences_v1 field: old supported clients omit it
-- and preserve their current value; newer clients can set it explicitly.

create or replace function public.sync_authoritative_preferences(p_user_id uuid)
returns jsonb language sql stable security definer set search_path = public as $$
  select jsonb_build_object(
    'contract_version', 'preferences_v1',
    'preferred_locale', p.preferred_locale,
    'weekly_goal_days', p.weekly_goal_days,
    'experience_level', coalesce(up.experience_level, 'beginner'::public.difficulty_level),
    'position_ids', coalesce((select jsonb_agg(pp.position_id order by pp.position_id) from public.user_preferred_positions pp where pp.user_id = p_user_id), '[]'::jsonb),
    'sound_enabled', coalesce(up.sound_enabled, true),
    'vibration_enabled', coalesce(up.vibration_enabled, true),
    'download_on_wifi_only', coalesce(up.download_on_wifi_only, true),
    'reminders_enabled', coalesce(up.reminders_enabled, false),
    'analytics_consent', coalesce(up.analytics_consent, false),
    'crash_reporting_consent', coalesce(up.crash_reporting_consent, false),
    'operation_at', up.operation_at, 'updated_at', up.updated_at
  )
  from public.profiles p left join public.user_preferences up on up.user_id = p.user_id
  where p.user_id = p_user_id;
$$;

-- Preserve the fully-tested v1 validator and wrap only the additive field.
-- Removing the optional key before delegation keeps the original exact-field
-- validation and every existing operation kind unchanged.
alter function public.sync_validate_push_operation(jsonb) rename to sync_validate_push_operation_preferences_v1;
create function public.sync_validate_push_operation(p_operation jsonb)
returns void language plpgsql stable security definer set search_path = public as $$
declare v_kind text := p_operation->>'kind'; v_payload jsonb := p_operation->'payload'; v_experience text;
begin
  if v_kind = 'preference_upsert' and v_payload ? 'experience_level' then
    perform public.sync_validate_push_operation_preferences_v1(
      jsonb_set(p_operation, '{payload}', v_payload - 'experience_level')
    );
    if jsonb_typeof(v_payload->'experience_level') <> 'string' then
      raise exception 'experience_level must be a string';
    end if;
    v_experience := v_payload->>'experience_level';
    if v_experience not in ('beginner', 'intermediate', 'advanced') then
      raise exception 'invalid experience_level';
    end if;
  else
    perform public.sync_validate_push_operation_preferences_v1(p_operation);
  end if;
end $$;

-- Keep the previous trusted implementation as an internal compatibility layer.
-- It still owns idempotency, LWW, ownership, and all non-preference writes.
alter function public.sync_push_user_data(jsonb) rename to sync_push_user_data_preferences_v1;
create function public.sync_push_user_data(p_operations jsonb)
returns jsonb language plpgsql security definer set search_path = public as $$
declare
  v_result jsonb;
  v_operations jsonb;
  v_operation jsonb;
  v_response jsonb;
  v_index bigint;
  v_experience text;
begin
  -- The prior function validates the complete request and enforces auth.uid().
  v_result := public.sync_push_user_data_preferences_v1(p_operations);
  v_operations := v_result->'operations';

  for v_operation, v_index in
    select value, ordinality from jsonb_array_elements(p_operations) with ordinality
  loop
    if v_operation->>'kind' <> 'preference_upsert'
       or not (v_operation->'payload' ? 'experience_level') then
      continue;
    end if;
    v_response := v_operations->((v_index - 1)::integer);
    v_experience := v_operation->'payload'->>'experience_level';

    -- Only a newly applied LWW document changes stored state. Replays and
    -- superseded writes return the current authoritative projection unchanged.
    if v_response->>'status' = 'applied' then
      update public.user_preferences
         set experience_level = v_experience::public.difficulty_level
       where user_id = auth.uid();
    end if;
    v_operations := jsonb_set(
      v_operations,
      array[(v_index - 1)::text, 'preferences'],
      public.sync_authoritative_preferences(auth.uid()),
      true
    );
  end loop;

  return v_result || jsonb_build_object(
    'operations', v_operations,
    'projections', public.sync_authoritative_projections(auth.uid())
  );
end $$;

-- The compatibility implementations must not become an API bypass.
revoke all on function public.sync_validate_push_operation_preferences_v1(jsonb) from public, anon, authenticated;
revoke all on function public.sync_push_user_data_preferences_v1(jsonb) from public, anon, authenticated;
revoke all on function public.sync_validate_push_operation(jsonb) from public, anon, authenticated;
revoke all on function public.sync_push_user_data(jsonb) from public, anon, authenticated;
grant execute on function public.sync_push_user_data(jsonb) to authenticated;
revoke all on function public.sync_authoritative_preferences(uuid) from public, anon, authenticated;
