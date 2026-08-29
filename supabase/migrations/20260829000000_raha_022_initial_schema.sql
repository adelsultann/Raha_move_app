-- RAHA-022 initial cloud schema. Apply only to a new Supabase project.
create extension if not exists pgcrypto;

create type public.content_status as enum ('draft', 'review', 'published', 'retired');
create type public.difficulty_level as enum ('beginner', 'intermediate', 'advanced');
create type public.session_status as enum ('in_progress', 'completed', 'abandoned');
create type public.step_status as enum ('pending', 'completed', 'partial', 'skipped');
create type public.feedback_rating as enum ('much_better', 'little_better', 'same', 'less_comfortable');
create type public.media_type as enum ('video', 'image', 'animation', 'audio');
create type public.access_tier as enum ('free', 'premium');

create function public.set_updated_at() returns trigger language plpgsql as $$
begin new.updated_at = now(); return new; end $$;

create table public.profiles (
  user_id uuid primary key references auth.users(id) on delete cascade,
  display_name text check (char_length(display_name) <= 80),
  preferred_locale text not null default 'ar' check (preferred_locale in ('ar', 'en')),
  timezone text not null default 'Asia/Riyadh' check (char_length(timezone) between 1 and 64),
  onboarding_completed_at timestamptz,
  weekly_goal_days smallint not null default 3 check (weekly_goal_days between 1 and 7),
  created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);
create table public.user_preferences (
  user_id uuid primary key references public.profiles(user_id) on delete cascade,
  experience_level public.difficulty_level not null default 'beginner', sound_enabled boolean not null default true,
  vibration_enabled boolean not null default true, download_on_wifi_only boolean not null default true,
  text_scale numeric(3,2) check (text_scale between 0.80 and 2.00),
  updated_at timestamptz not null default now()
);
create table public.reminder_schedules (
  id uuid primary key default gen_random_uuid(), user_id uuid not null references public.profiles(user_id) on delete cascade,
  local_time time not null, days_of_week smallint[] not null check (cardinality(days_of_week) between 1 and 7 and days_of_week <@ array[1,2,3,4,5,6,7]::smallint[]),
  timezone text not null check (char_length(timezone) between 1 and 64), enabled boolean not null default true,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(), unique (user_id, local_time, timezone)
);

create table public.content_providers (
  id uuid primary key default gen_random_uuid(), key text not null unique check (key ~ '^[a-z0-9_]+$'), name text not null,
  license_type text not null, license_reference text not null, allowed_platforms text[] not null default '{}',
  attribution_required boolean not null default false, license_expires_at timestamptz, internal_notes text,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);
create table public.content_releases (
  id bigint generated always as identity primary key, version text not null unique, published_at timestamptz not null,
  minimum_app_version text, manifest_checksum text not null check (char_length(manifest_checksum) = 64), created_at timestamptz not null default now()
);
create table public.exercises (
  id uuid primary key default gen_random_uuid(), public_id text not null unique check (public_id ~ '^raha_ex_[a-z0-9_]+$'),
  status public.content_status not null default 'draft', difficulty public.difficulty_level not null,
  access_tier public.access_tier not null default 'free', default_points smallint not null default 0 check (default_points >= 0),
  release_id bigint references public.content_releases(id) on delete restrict, created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);
create table public.exercise_translations (
  exercise_id uuid not null references public.exercises(id) on delete restrict, locale text not null check (locale in ('ar', 'en')),
  name text not null check (char_length(name) between 1 and 160), description text, short_cue text,
  primary key (exercise_id, locale)
);
create table public.provider_exercises (
  provider_id uuid not null references public.content_providers(id) on delete restrict, source_exercise_id text not null,
  exercise_id uuid not null references public.exercises(id) on delete restrict, source_payload jsonb not null,
  source_updated_at timestamptz, imported_at timestamptz not null default now(), primary key (provider_id, source_exercise_id)
);
create table public.media_assets (
  id uuid primary key default gen_random_uuid(), exercise_id uuid not null references public.exercises(id) on delete restrict,
  provider_id uuid references public.content_providers(id) on delete restrict, media_type public.media_type not null,
  storage_bucket text not null check (char_length(storage_bucket) between 1 and 63), storage_key text not null check (storage_key !~* '^https?://'),
  mime_type text not null, width integer check (width > 0), height integer check (height > 0), duration_ms integer check (duration_ms > 0),
  checksum_sha256 text not null check (checksum_sha256 ~ '^[0-9a-f]{64}$'), is_preferred boolean not null default false,
  status public.content_status not null default 'draft', created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  unique (storage_bucket, storage_key)
);
create unique index media_assets_one_preferred_published on public.media_assets(exercise_id, media_type) where is_preferred and status = 'published';

create table public.body_areas (id uuid primary key default gen_random_uuid(), key text not null unique check (key ~ '^[a-z0-9_]+$'), sort_order smallint not null default 0, active boolean not null default true);
create table public.goals (id uuid primary key default gen_random_uuid(), key text not null unique check (key ~ '^[a-z0-9_]+$'), sort_order smallint not null default 0, active boolean not null default true);
create table public.movement_positions (id uuid primary key default gen_random_uuid(), key text not null unique check (key ~ '^[a-z0-9_]+$'), sort_order smallint not null default 0, active boolean not null default true);
create table public.equipment (id uuid primary key default gen_random_uuid(), key text not null unique check (key ~ '^[a-z0-9_]+$'), sort_order smallint not null default 0, active boolean not null default true);
create table public.routine_contexts (id uuid primary key default gen_random_uuid(), key text not null unique check (key ~ '^[a-z0-9_]+$'), sort_order smallint not null default 0, active boolean not null default true);
create table public.tags (id uuid primary key default gen_random_uuid(), key text not null unique check (key ~ '^[a-z0-9_]+$'), sort_order smallint not null default 0, active boolean not null default true);
create table public.body_area_translations (body_area_id uuid not null references public.body_areas(id) on delete cascade, locale text not null check (locale in ('ar','en')), name text not null, primary key(body_area_id, locale));
create table public.goal_translations (goal_id uuid not null references public.goals(id) on delete cascade, locale text not null check (locale in ('ar','en')), name text not null, primary key(goal_id, locale));
create table public.movement_position_translations (position_id uuid not null references public.movement_positions(id) on delete cascade, locale text not null check (locale in ('ar','en')), name text not null, primary key(position_id, locale));
create table public.equipment_translations (equipment_id uuid not null references public.equipment(id) on delete cascade, locale text not null check (locale in ('ar','en')), name text not null, primary key(equipment_id, locale));
create table public.routine_context_translations (context_id uuid not null references public.routine_contexts(id) on delete cascade, locale text not null check (locale in ('ar','en')), name text not null, primary key(context_id, locale));
create table public.tag_translations (tag_id uuid not null references public.tags(id) on delete cascade, locale text not null check (locale in ('ar','en')), name text not null, primary key(tag_id, locale));

create table public.routines (
  id uuid primary key default gen_random_uuid(), public_id text not null unique check (public_id ~ '^raha_rt_[a-z0-9_]+$'),
  status public.content_status not null default 'draft', difficulty public.difficulty_level not null, access_tier public.access_tier not null default 'free',
  estimated_duration_seconds integer not null check (estimated_duration_seconds > 0), version integer not null default 1 check (version > 0), published_at timestamptz,
  release_id bigint references public.content_releases(id) on delete restrict, created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  check ((status <> 'published') or published_at is not null)
);
create table public.routine_translations (routine_id uuid not null references public.routines(id) on delete restrict, locale text not null check (locale in ('ar','en')), name text not null check (char_length(name) between 1 and 160), summary text not null, primary key(routine_id, locale));
create table public.routine_steps (
  id uuid primary key default gen_random_uuid(), routine_id uuid not null references public.routines(id) on delete restrict,
  exercise_id uuid not null references public.exercises(id) on delete restrict, position smallint not null check (position > 0),
  duration_seconds integer check (duration_seconds > 0), repetition_count smallint check (repetition_count > 0), rest_after_seconds smallint not null default 0 check (rest_after_seconds >= 0),
  side_mode text check (side_mode in ('alternating','left','right','both')), is_optional boolean not null default false,
  unique(routine_id, position), check ((duration_seconds is null) <> (repetition_count is null))
);
create table public.exercise_body_areas (exercise_id uuid references public.exercises(id) on delete restrict, body_area_id uuid references public.body_areas(id) on delete restrict, relevance_weight smallint not null default 1 check (relevance_weight between 1 and 100), primary key(exercise_id, body_area_id));
create table public.exercise_positions (exercise_id uuid references public.exercises(id) on delete restrict, position_id uuid references public.movement_positions(id) on delete restrict, primary key(exercise_id, position_id));
create table public.exercise_equipment (exercise_id uuid references public.exercises(id) on delete restrict, equipment_id uuid references public.equipment(id) on delete restrict, primary key(exercise_id, equipment_id));
create table public.exercise_goals (exercise_id uuid references public.exercises(id) on delete restrict, goal_id uuid references public.goals(id) on delete restrict, primary key(exercise_id, goal_id));
create table public.exercise_tags (exercise_id uuid references public.exercises(id) on delete restrict, tag_id uuid references public.tags(id) on delete restrict, primary key(exercise_id, tag_id));
create table public.routine_body_areas (routine_id uuid references public.routines(id) on delete restrict, body_area_id uuid references public.body_areas(id) on delete restrict, relevance_weight smallint not null default 1 check (relevance_weight between 1 and 100), primary key(routine_id, body_area_id));
create table public.routine_goals (routine_id uuid references public.routines(id) on delete restrict, goal_id uuid references public.goals(id) on delete restrict, relevance_weight smallint not null default 1 check (relevance_weight between 1 and 100), primary key(routine_id, goal_id));
create table public.routine_positions (routine_id uuid references public.routines(id) on delete restrict, position_id uuid references public.movement_positions(id) on delete restrict, primary key(routine_id, position_id));
create table public.routine_context_memberships (routine_id uuid references public.routines(id) on delete restrict, context_id uuid references public.routine_contexts(id) on delete restrict, primary key(routine_id, context_id));
create table public.routine_equipment (routine_id uuid references public.routines(id) on delete restrict, equipment_id uuid references public.equipment(id) on delete restrict, primary key(routine_id, equipment_id));

create table public.user_preferred_positions (user_id uuid references public.profiles(user_id) on delete cascade, position_id uuid references public.movement_positions(id) on delete restrict, primary key(user_id, position_id));
create table public.user_avoided_exercises (user_id uuid references public.profiles(user_id) on delete cascade, exercise_id uuid references public.exercises(id) on delete restrict, reason_code text not null check (char_length(reason_code) between 1 and 64), note text check (char_length(note) <= 500), created_at timestamptz not null default now(), primary key(user_id, exercise_id));
create table public.user_body_area_preferences (user_id uuid references public.profiles(user_id) on delete cascade, body_area_id uuid references public.body_areas(id) on delete restrict, preference_type text not null check (preference_type in ('preferred','avoid')), primary key(user_id, body_area_id));
create table public.check_ins (id uuid primary key default gen_random_uuid(), user_id uuid not null references public.profiles(user_id) on delete cascade, body_state text not null check (body_state in ('comfortable','stiff','tired','tense')), goal_id uuid not null references public.goals(id) on delete restrict, available_minutes smallint not null check (available_minutes in (3,5,10,15)), position_id uuid references public.movement_positions(id) on delete restrict, started_at timestamptz not null, completed_at timestamptz, created_at timestamptz not null default now(), updated_at timestamptz not null default now(), check (completed_at is null or completed_at >= started_at));
create table public.check_in_body_areas (check_in_id uuid not null references public.check_ins(id) on delete cascade, body_area_id uuid not null references public.body_areas(id) on delete restrict, primary key(check_in_id, body_area_id));
create table public.recommendation_rule_sets (version text primary key, configuration jsonb not null, active_from timestamptz not null, retired_at timestamptz, created_at timestamptz not null default now(), check (retired_at is null or retired_at >= active_from));
create table public.recommendations (id uuid primary key default gen_random_uuid(), user_id uuid not null references public.profiles(user_id) on delete cascade, check_in_id uuid not null references public.check_ins(id) on delete cascade, routine_id uuid not null references public.routines(id) on delete restrict, engine_version text not null references public.recommendation_rule_sets(version) on delete restrict, rank smallint not null check (rank > 0), score integer not null, reason_codes text[] not null default '{}', shown_at timestamptz not null, accepted_at timestamptz, rejected_at timestamptz, rejection_reason text check (rejection_reason in ('too_easy','too_difficult','position','discomfort','other')), created_at timestamptz not null default now(), updated_at timestamptz not null default now(), check (not (accepted_at is not null and rejected_at is not null)));

create table public.routine_sessions (
  id uuid primary key default gen_random_uuid(), user_id uuid not null references public.profiles(user_id) on delete cascade,
  routine_id uuid not null references public.routines(id) on delete restrict, routine_version integer not null check (routine_version > 0), recommendation_id uuid references public.recommendations(id) on delete set null,
  status public.session_status not null default 'in_progress', started_at timestamptz not null, completed_at timestamptz,
  target_duration_seconds integer not null check (target_duration_seconds >= 0), actual_duration_seconds integer not null default 0 check (actual_duration_seconds between 0 and target_duration_seconds),
  total_step_count_snapshot smallint not null check (total_step_count_snapshot >= 0), steps_completed smallint not null default 0 check (steps_completed >= 0), steps_partial smallint not null default 0 check (steps_partial >= 0), steps_skipped smallint not null default 0 check (steps_skipped >= 0),
  completion_policy_version text not null, source text not null check (source in ('recommendation','explore','saved','repeat','bundled')),
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  check (steps_completed + steps_partial + steps_skipped <= total_step_count_snapshot),
  check ((status = 'in_progress' and completed_at is null) or (status <> 'in_progress' and completed_at is not null and completed_at >= started_at)),
  check (status <> 'completed' or (actual_duration_seconds * 100 >= target_duration_seconds * 80 and steps_skipped <= floor(total_step_count_snapshot * 0.20)))
);
create function public.prevent_session_reopen() returns trigger language plpgsql as $$ begin if old.status <> 'in_progress' and new.status = 'in_progress' then raise exception 'terminal sessions cannot return to in_progress'; end if; return new; end $$;
create trigger routine_sessions_no_reopen before update on public.routine_sessions for each row execute function public.prevent_session_reopen();
create table public.session_steps (session_id uuid not null references public.routine_sessions(id) on delete cascade, routine_step_id uuid not null references public.routine_steps(id) on delete restrict, exercise_id_snapshot uuid not null references public.exercises(id) on delete restrict, position_snapshot smallint not null check (position_snapshot > 0), status public.step_status not null default 'pending', target_duration_seconds integer check (target_duration_seconds is null or target_duration_seconds > 0), active_duration_seconds integer not null default 0 check (active_duration_seconds >= 0), skip_requested boolean not null default false, started_at timestamptz, finished_at timestamptz, primary key(session_id, routine_step_id), unique(session_id, position_snapshot), check (target_duration_seconds is null or active_duration_seconds <= target_duration_seconds), check (finished_at is null or started_at is null or finished_at >= started_at), check (status <> 'skipped' or active_duration_seconds = 0), check (status <> 'partial' or active_duration_seconds > 0));
create table public.session_feedback (session_id uuid primary key references public.routine_sessions(id) on delete cascade, user_id uuid not null references public.profiles(user_id) on delete cascade, rating public.feedback_rating not null, uncomfortable_exercise_id uuid references public.exercises(id) on delete restrict, note text check (char_length(note) <= 500), created_at timestamptz not null default now(), updated_at timestamptz not null default now());
create table public.saved_routines (user_id uuid not null references public.profiles(user_id) on delete cascade, routine_id uuid not null references public.routines(id) on delete restrict, created_at timestamptz not null default now(), updated_at timestamptz not null default now(), deleted_at timestamptz, primary key(user_id, routine_id));

create table public.point_ledger (id uuid primary key default gen_random_uuid(), user_id uuid not null references public.profiles(user_id) on delete cascade, points integer not null, reason_code text not null, source_type text not null, source_id uuid, created_at timestamptz not null default now());
create unique index point_ledger_idempotent_source on public.point_ledger(user_id, reason_code, source_type, source_id) where source_id is not null;
create table public.achievements (id uuid primary key default gen_random_uuid(), key text not null unique check (key ~ '^[a-z0-9_]+$'), category text not null, criteria_version integer not null check (criteria_version > 0), criteria jsonb not null, points smallint not null default 0 check (points >= 0), status public.content_status not null default 'draft', created_at timestamptz not null default now(), updated_at timestamptz not null default now());
create table public.achievement_translations (achievement_id uuid not null references public.achievements(id) on delete restrict, locale text not null check (locale in ('ar','en')), name text not null, description text not null, primary key(achievement_id, locale));
create table public.user_achievements (user_id uuid not null references public.profiles(user_id) on delete cascade, achievement_id uuid not null references public.achievements(id) on delete restrict, earned_at timestamptz not null default now(), source_id uuid, criteria_version integer not null check (criteria_version > 0), primary key(user_id, achievement_id));
create table public.user_streaks (user_id uuid primary key references public.profiles(user_id) on delete cascade, current_streak_days integer not null default 0 check(current_streak_days >= 0), longest_streak_days integer not null default 0 check(longest_streak_days >= current_streak_days), last_movement_date date, rule_version text not null, updated_at timestamptz not null default now());
create table public.user_entitlements (user_id uuid not null references public.profiles(user_id) on delete cascade, entitlement_key text not null, is_active boolean not null, product_id text, expires_at timestamptz, environment text not null check(environment in ('sandbox','production')), provider_event_id text not null unique, updated_at timestamptz not null default now(), primary key(user_id, entitlement_key));

create index exercises_catalog_cursor on public.exercises(status, access_tier, updated_at);
create index routines_catalog_cursor on public.routines(status, access_tier, updated_at);
create index media_assets_delivery on public.media_assets(exercise_id, status, is_preferred);
create index check_ins_owner_completed on public.check_ins(user_id, completed_at desc);
create index recommendations_owner_shown on public.recommendations(user_id, shown_at desc);
create index sessions_owner_started on public.routine_sessions(user_id, started_at desc);
create index sessions_owner_status on public.routine_sessions(user_id, status, updated_at);
create index feedback_owner_created on public.session_feedback(user_id, created_at desc);
create index point_ledger_owner_created on public.point_ledger(user_id, created_at desc);
create index achievements_owner_earned on public.user_achievements(user_id, earned_at desc);
create index session_steps_session on public.session_steps(session_id);
create index check_in_body_areas_area on public.check_in_body_areas(body_area_id);

create trigger profiles_updated_at before update on public.profiles for each row execute function public.set_updated_at();
create trigger preferences_updated_at before update on public.user_preferences for each row execute function public.set_updated_at();
create trigger reminders_updated_at before update on public.reminder_schedules for each row execute function public.set_updated_at();
create trigger exercises_updated_at before update on public.exercises for each row execute function public.set_updated_at();
create trigger providers_updated_at before update on public.content_providers for each row execute function public.set_updated_at();
create trigger media_updated_at before update on public.media_assets for each row execute function public.set_updated_at();
create trigger routines_updated_at before update on public.routines for each row execute function public.set_updated_at();
create trigger check_ins_updated_at before update on public.check_ins for each row execute function public.set_updated_at();
create trigger recommendations_updated_at before update on public.recommendations for each row execute function public.set_updated_at();
create trigger sessions_updated_at before update on public.routine_sessions for each row execute function public.set_updated_at();
create trigger feedback_updated_at before update on public.session_feedback for each row execute function public.set_updated_at();
create trigger saved_routines_updated_at before update on public.saved_routines for each row execute function public.set_updated_at();
create trigger achievements_updated_at before update on public.achievements for each row execute function public.set_updated_at();
create trigger streaks_updated_at before update on public.user_streaks for each row execute function public.set_updated_at();

-- Explicit projections avoid private provider fields and optional feedback notes.
create view public.mobile_session_feedback with (security_invoker = true) as select session_id, user_id, rating, uncomfortable_exercise_id, created_at, updated_at from public.session_feedback;

alter table public.profiles enable row level security; alter table public.user_preferences enable row level security; alter table public.reminder_schedules enable row level security;
alter table public.content_providers enable row level security; alter table public.content_releases enable row level security; alter table public.exercises enable row level security; alter table public.exercise_translations enable row level security; alter table public.provider_exercises enable row level security; alter table public.media_assets enable row level security;
alter table public.body_areas enable row level security; alter table public.goals enable row level security; alter table public.movement_positions enable row level security; alter table public.equipment enable row level security; alter table public.routine_contexts enable row level security; alter table public.tags enable row level security;
alter table public.body_area_translations enable row level security; alter table public.goal_translations enable row level security; alter table public.movement_position_translations enable row level security; alter table public.equipment_translations enable row level security; alter table public.routine_context_translations enable row level security; alter table public.tag_translations enable row level security;
alter table public.routines enable row level security; alter table public.routine_translations enable row level security; alter table public.routine_steps enable row level security; alter table public.exercise_body_areas enable row level security; alter table public.exercise_positions enable row level security; alter table public.exercise_equipment enable row level security; alter table public.exercise_goals enable row level security; alter table public.exercise_tags enable row level security; alter table public.routine_body_areas enable row level security; alter table public.routine_goals enable row level security; alter table public.routine_positions enable row level security; alter table public.routine_context_memberships enable row level security; alter table public.routine_equipment enable row level security;
alter table public.user_preferred_positions enable row level security; alter table public.user_avoided_exercises enable row level security; alter table public.user_body_area_preferences enable row level security; alter table public.check_ins enable row level security; alter table public.check_in_body_areas enable row level security; alter table public.recommendation_rule_sets enable row level security; alter table public.recommendations enable row level security; alter table public.routine_sessions enable row level security; alter table public.session_steps enable row level security; alter table public.session_feedback enable row level security; alter table public.saved_routines enable row level security; alter table public.point_ledger enable row level security; alter table public.achievements enable row level security; alter table public.achievement_translations enable row level security; alter table public.user_achievements enable row level security; alter table public.user_streaks enable row level security; alter table public.user_entitlements enable row level security;

-- Catalog access is deliberately free-only until an entitlement authorization design is approved.
create policy catalog_releases_read on public.content_releases for select to anon, authenticated using (published_at <= now());
create policy catalog_exercises_read on public.exercises for select to anon, authenticated using (status = 'published' and access_tier = 'free' and release_id is not null and exists (select 1 from public.content_releases r where r.id = release_id and r.published_at <= now()));
create policy catalog_routines_read on public.routines for select to anon, authenticated using (status = 'published' and access_tier = 'free' and published_at <= now() and release_id is not null and exists (select 1 from public.content_releases r where r.id = release_id and r.published_at <= now()));
create policy catalog_media_read on public.media_assets for select to anon, authenticated using (status = 'published' and exists (select 1 from public.exercises e where e.id = exercise_id and e.status = 'published' and e.access_tier = 'free' and e.release_id is not null));
create policy catalog_exercise_translations_read on public.exercise_translations for select to anon, authenticated using (exists (select 1 from public.exercises e where e.id = exercise_id and e.status = 'published' and e.access_tier = 'free' and e.release_id is not null));
create policy catalog_routine_translations_read on public.routine_translations for select to anon, authenticated using (exists (select 1 from public.routines r where r.id = routine_id and r.status = 'published' and r.access_tier = 'free' and r.release_id is not null));
create policy catalog_routine_steps_read on public.routine_steps for select to anon, authenticated using (exists (select 1 from public.routines r join public.exercises e on e.id = exercise_id where r.id = routine_id and r.status = 'published' and r.access_tier = 'free' and r.release_id is not null and e.status = 'published' and e.access_tier = 'free'));
create policy catalog_rule_sets_read on public.recommendation_rule_sets for select to anon, authenticated using (active_from <= now() and (retired_at is null or retired_at > now()));
create policy catalog_achievements_read on public.achievements for select to anon, authenticated using (status = 'published');
create policy catalog_achievement_translations_read on public.achievement_translations for select to anon, authenticated using (exists (select 1 from public.achievements a where a.id = achievement_id and a.status = 'published'));
create policy catalog_body_areas_read on public.body_areas for select to anon, authenticated using (active); create policy catalog_goals_read on public.goals for select to anon, authenticated using (active); create policy catalog_positions_read on public.movement_positions for select to anon, authenticated using (active); create policy catalog_equipment_read on public.equipment for select to anon, authenticated using (active); create policy catalog_contexts_read on public.routine_contexts for select to anon, authenticated using (active); create policy catalog_tags_read on public.tags for select to anon, authenticated using (active);
create policy catalog_body_area_translations_read on public.body_area_translations for select to anon, authenticated using (exists (select 1 from public.body_areas x where x.id = body_area_id and x.active)); create policy catalog_goal_translations_read on public.goal_translations for select to anon, authenticated using (exists (select 1 from public.goals x where x.id = goal_id and x.active)); create policy catalog_position_translations_read on public.movement_position_translations for select to anon, authenticated using (exists (select 1 from public.movement_positions x where x.id = position_id and x.active)); create policy catalog_equipment_translations_read on public.equipment_translations for select to anon, authenticated using (exists (select 1 from public.equipment x where x.id = equipment_id and x.active)); create policy catalog_context_translations_read on public.routine_context_translations for select to anon, authenticated using (exists (select 1 from public.routine_contexts x where x.id = context_id and x.active)); create policy catalog_tag_translations_read on public.tag_translations for select to anon, authenticated using (exists (select 1 from public.tags x where x.id = tag_id and x.active));
create policy catalog_exercise_body_areas_read on public.exercise_body_areas for select to anon, authenticated using (exists (select 1 from public.exercises e where e.id = exercise_id and e.status = 'published' and e.access_tier = 'free')); create policy catalog_exercise_positions_read on public.exercise_positions for select to anon, authenticated using (exists (select 1 from public.exercises e where e.id = exercise_id and e.status = 'published' and e.access_tier = 'free')); create policy catalog_exercise_equipment_read on public.exercise_equipment for select to anon, authenticated using (exists (select 1 from public.exercises e where e.id = exercise_id and e.status = 'published' and e.access_tier = 'free')); create policy catalog_exercise_goals_read on public.exercise_goals for select to anon, authenticated using (exists (select 1 from public.exercises e where e.id = exercise_id and e.status = 'published' and e.access_tier = 'free')); create policy catalog_exercise_tags_read on public.exercise_tags for select to anon, authenticated using (exists (select 1 from public.exercises e where e.id = exercise_id and e.status = 'published' and e.access_tier = 'free'));
create policy catalog_routine_body_areas_read on public.routine_body_areas for select to anon, authenticated using (exists (select 1 from public.routines r where r.id = routine_id and r.status = 'published' and r.access_tier = 'free')); create policy catalog_routine_goals_read on public.routine_goals for select to anon, authenticated using (exists (select 1 from public.routines r where r.id = routine_id and r.status = 'published' and r.access_tier = 'free')); create policy catalog_routine_positions_read on public.routine_positions for select to anon, authenticated using (exists (select 1 from public.routines r where r.id = routine_id and r.status = 'published' and r.access_tier = 'free')); create policy catalog_routine_contexts_read on public.routine_context_memberships for select to anon, authenticated using (exists (select 1 from public.routines r where r.id = routine_id and r.status = 'published' and r.access_tier = 'free')); create policy catalog_routine_equipment_read on public.routine_equipment for select to anon, authenticated using (exists (select 1 from public.routines r where r.id = routine_id and r.status = 'published' and r.access_tier = 'free'));

create policy own_profiles on public.profiles for all to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy own_preferences on public.user_preferences for all to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy own_reminders on public.reminder_schedules for all to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy own_preferred_positions on public.user_preferred_positions for all to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy own_avoided_exercises on public.user_avoided_exercises for all to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy own_body_area_preferences on public.user_body_area_preferences for all to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy own_check_ins on public.check_ins for all to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy own_check_in_areas on public.check_in_body_areas for all to authenticated using (exists (select 1 from public.check_ins c where c.id = check_in_id and c.user_id = auth.uid())) with check (exists (select 1 from public.check_ins c where c.id = check_in_id and c.user_id = auth.uid()));
create policy own_recommendations on public.recommendations for all to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid() and exists (select 1 from public.check_ins c where c.id = check_in_id and c.user_id = auth.uid()));
create policy own_sessions on public.routine_sessions for all to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid() and (recommendation_id is null or exists (select 1 from public.recommendations r where r.id = recommendation_id and r.user_id = auth.uid())));
create policy own_session_steps on public.session_steps for all to authenticated using (exists (select 1 from public.routine_sessions s where s.id = session_id and s.user_id = auth.uid())) with check (exists (select 1 from public.routine_sessions s where s.id = session_id and s.user_id = auth.uid()));
create policy own_feedback on public.session_feedback for all to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid() and exists (select 1 from public.routine_sessions s where s.id = session_id and s.user_id = auth.uid() and s.status = 'completed'));
create policy own_saved_routines on public.saved_routines for all to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy own_point_ledger_read on public.point_ledger for select to authenticated using (user_id = auth.uid());
create policy own_achievements_read on public.user_achievements for select to authenticated using (user_id = auth.uid());
create policy own_streak_read on public.user_streaks for select to authenticated using (user_id = auth.uid());
create policy own_entitlements_read on public.user_entitlements for select to authenticated using (user_id = auth.uid());

revoke all on all tables in schema public from anon, authenticated;
grant usage on schema public to anon, authenticated;
grant select on public.content_releases, public.exercises, public.exercise_translations, public.media_assets, public.body_areas, public.goals, public.movement_positions, public.equipment, public.routine_contexts, public.tags, public.body_area_translations, public.goal_translations, public.movement_position_translations, public.equipment_translations, public.routine_context_translations, public.tag_translations, public.routines, public.routine_translations, public.routine_steps, public.exercise_body_areas, public.exercise_positions, public.exercise_equipment, public.exercise_goals, public.exercise_tags, public.routine_body_areas, public.routine_goals, public.routine_positions, public.routine_context_memberships, public.routine_equipment, public.recommendation_rule_sets, public.achievements, public.achievement_translations to anon, authenticated;
grant select, insert, update, delete on public.profiles, public.user_preferences, public.reminder_schedules, public.user_preferred_positions, public.user_avoided_exercises, public.user_body_area_preferences, public.check_ins, public.check_in_body_areas, public.recommendations, public.routine_sessions, public.session_steps, public.session_feedback, public.saved_routines to authenticated;
grant select on public.point_ledger, public.user_achievements, public.user_streaks, public.user_entitlements, public.mobile_session_feedback to authenticated;
