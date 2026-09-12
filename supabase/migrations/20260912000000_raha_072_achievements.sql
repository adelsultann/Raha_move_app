-- RAHA-072: server-owned, versioned achievements and achievement projection.
-- The initial catalog recognizes participation only. It does not award points,
-- rank people, or depend on feedback, pain, range of motion, or provider data.

alter table public.achievements
  add column if not exists icon_key text not null default 'workspace_premium';
alter table public.achievements
  add constraint achievements_icon_key_len check (char_length(icon_key) between 1 and 64);

-- Stable Raha-owned keys, app-owned icon keys, and versioned criteria. The
-- criteria remain immutable in meaning: change a rule by adding a new version,
-- never by rewriting a previously awarded rule.
insert into public.achievements(key, category, criteria_version, criteria, points, icon_key, status)
values
  ('first_step', 'getting_started', 1,
   '{"rule_type":"completed_session_count","threshold":1,"rule_version":"achievement_sessions_v1"}'::jsonb,
   0, 'first_step', 'published'),
  ('gentle_habit_7', 'consistency', 1,
   '{"rule_type":"completed_session_count","threshold":7,"rule_version":"achievement_sessions_v1"}'::jsonb,
   0, 'gentle_habit', 'published')
on conflict (key) do nothing;

insert into public.achievement_translations(achievement_id, locale, name, description)
select a.id, t.locale, t.name, t.description
from public.achievements a
join (values
  ('first_step', 'en', 'First Step', 'You completed your first routine.'),
  ('first_step', 'ar', 'خطوتك الأولى', 'أكملت روتينك الأول.'),
  ('gentle_habit_7', 'en', 'A Gentle Habit', 'Seven completed routines, at your own pace.'),
  ('gentle_habit_7', 'ar', 'عادة لطيفة', 'أكملت سبعة روتينات، بوتيرتك الخاصة.')
) as t(key, locale, name, description) on t.key = a.key
where a.key in ('first_step', 'gentle_habit_7')
on conflict (achievement_id, locale) do nothing;

-- Trusted evaluation reads only server-accepted completed sessions. The primary
-- key on user_achievements is the final idempotency boundary for concurrent
-- finalization or delayed/replayed offline synchronization.
create or replace function public.award_completion_achievements(p_session_id uuid)
returns void
language plpgsql security definer set search_path = public as $$
declare session_row public.routine_sessions%rowtype;
begin
  select * into session_row from public.routine_sessions
  where id = p_session_id and status = 'completed';
  if not found then return; end if;

  insert into public.user_achievements(
    user_id, achievement_id, earned_at, source_id, criteria_version
  )
  select session_row.user_id, a.id, session_row.completed_at, session_row.id,
         a.criteria_version
  from public.achievements a
  where a.status = 'published'
    and a.criteria->>'rule_type' = 'completed_session_count'
    and (a.criteria->>'threshold')::integer <= (
      select count(*) from public.routine_sessions s
      where s.user_id = session_row.user_id and s.status = 'completed'
    )
  on conflict (user_id, achievement_id) do nothing;
end $$;

-- Historical completed sessions retain their historical source and completion
-- time if the catalog is introduced after the session was accepted.
insert into public.user_achievements(
  user_id, achievement_id, earned_at, source_id, criteria_version
)
select p.user_id, a.id, source.completed_at, source.id, a.criteria_version
from public.profiles p
join public.achievements a on a.status = 'published'
  and a.criteria->>'rule_type' = 'completed_session_count'
cross join lateral (
  select s.id, s.completed_at
  from public.routine_sessions s
  where s.user_id = p.user_id and s.status = 'completed'
  order by s.completed_at, s.id
  offset ((a.criteria->>'threshold')::integer - 1) limit 1
) source
on conflict (user_id, achievement_id) do nothing;

create or replace function public.award_achievements_on_completed_session()
returns trigger
language plpgsql security definer set search_path = public as $$
begin
  perform public.award_completion_achievements(new.id);
  return new;
end $$;

drop trigger if exists award_achievements_on_completed_session on public.routine_sessions;
create trigger award_achievements_on_completed_session
after insert or update of status, completed_at on public.routine_sessions
for each row when (new.status = 'completed')
execute function public.award_achievements_on_completed_session();

-- The client receives a public-safe catalog and its own award records through
-- the authenticated sync envelope only. Neither raw criteria evaluation nor
-- award creation is callable from mobile roles.
create or replace function public.achievement_projection(p_user_id uuid)
returns jsonb language sql stable security definer set search_path = public as $$
  select jsonb_build_object(
    'catalog', coalesce((
      select jsonb_agg(jsonb_build_object(
        'id', a.id, 'key', a.key, 'category', a.category,
        'criteria_version', a.criteria_version, 'criteria', a.criteria,
        'icon_key', a.icon_key, 'status', a.status,
        'translations', coalesce((
          select jsonb_object_agg(t.locale, jsonb_build_object(
            'title', t.name, 'description', t.description
          )) from public.achievement_translations t where t.achievement_id = a.id
        ), '{}'::jsonb)
      ) order by a.key)
      from public.achievements a
      where a.status = 'published'
         or exists (
           select 1 from public.user_achievements ua
           where ua.user_id = p_user_id and ua.achievement_id = a.id
         )
    ), '[]'::jsonb),
    'earned', coalesce((
      select jsonb_agg(jsonb_build_object(
        'achievement_id', ua.achievement_id, 'earned_at', ua.earned_at,
        'source_id', ua.source_id, 'criteria_version', ua.criteria_version
      ) order by ua.earned_at, ua.achievement_id)
      from public.user_achievements ua where ua.user_id = p_user_id
    ), '[]'::jsonb)
  )
$$;

create or replace function public.sync_authoritative_projections(p_user_id uuid)
returns jsonb language sql stable security definer set search_path = public as $$
  select jsonb_build_object(
    'points', coalesce((select jsonb_agg(jsonb_build_object('id',id,'points',points,'reason_code',reason_code,'rule_version',rule_version,'source_type',source_type,'source_id',source_id,'created_at',created_at) order by created_at,id) from public.point_ledger where user_id=p_user_id), '[]'::jsonb),
    'points_balance', coalesce((select sum(points)::integer from public.point_ledger where user_id=p_user_id), 0),
    'weekly_progress', public.weekly_movement_progress(p_user_id),
    'achievements', public.achievement_projection(p_user_id),
    'streak', public.streak_v1_projection(p_user_id),
    'entitlements', coalesce((select jsonb_agg(jsonb_build_object('entitlement_key',entitlement_key,'is_active',is_active,'product_id',product_id,'expires_at',expires_at,'environment',environment,'updated_at',updated_at) order by entitlement_key) from public.user_entitlements where user_id=p_user_id), '[]'::jsonb)
  )
$$;

revoke all on function public.award_completion_achievements(uuid) from public, anon, authenticated;
revoke all on function public.achievement_projection(uuid) from public, anon, authenticated;
