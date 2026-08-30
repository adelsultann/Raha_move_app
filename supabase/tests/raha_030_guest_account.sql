-- Local/disposable RAHA-030 guest identity profile bootstrap. Run after db reset.
begin;

-- The trigger must exist exactly once on auth.users. The drop/create in the
-- migration must not have left a duplicate, which would double-insert profiles.
do $$
declare n integer;
begin
  select count(*) into n from pg_trigger
  where tgrelid = 'auth.users'::regclass
    and tgname = 'auth_users_create_profile'
    and not tgisinternal;
  if n <> 1 then raise exception 'RAHA-030: auth_users_create_profile trigger must exist exactly once'; end if;
end $$;

-- A newly registered (non-anonymous) Auth user receives exactly one profile
-- with the table's safe defaults. Only user_id is populated by the trigger; no
-- email/phone/PII is copied into public.profiles.
insert into auth.users (id,aud,role,email,encrypted_password,email_confirmed_at,raw_app_meta_data,raw_user_meta_data,created_at,updated_at)
values ('03000000-0000-0000-0000-000000000001','authenticated','authenticated','raha030-registered@example.test','',now(),'{}','{}',now(),now());

do $$
declare p public.profiles%rowtype; n integer;
begin
  select count(*) into n from public.profiles where user_id = '03000000-0000-0000-0000-000000000001';
  if n <> 1 then raise exception 'RAHA-030: registered user must have exactly one profile'; end if;
  select * into p from public.profiles where user_id = '03000000-0000-0000-0000-000000000001';
  if p.preferred_locale <> 'ar'
     or p.timezone <> 'Asia/Riyadh'
     or p.weekly_goal_days <> 3
     or p.display_name is not null
     or p.onboarding_completed_at is not null then
    raise exception 'RAHA-030: profile must use safe defaults and copy no PII';
  end if;
end $$;

-- An anonymous guest Auth user also receives a profile. The local Supabase
-- image exposes auth.users.is_anonymous (boolean not null default false) when
-- enable_anonymous_sign_ins = true; assert it exists and exercise the path.
do $$
declare has_anonymous boolean;
begin
  select exists (
    select 1 from information_schema.columns
    where table_schema = 'auth' and table_name = 'users' and column_name = 'is_anonymous'
  ) into has_anonymous;
  if not has_anonymous then
    raise exception 'RAHA-030: auth.users.is_anonymous is expected in this Supabase schema';
  end if;
end $$;

insert into auth.users (id,aud,role,email,encrypted_password,email_confirmed_at,raw_app_meta_data,raw_user_meta_data,created_at,updated_at,is_anonymous)
values ('03000000-0000-0000-0000-000000000002','authenticated','authenticated',null,'',now(),'{"provider":"anonymous","providers":["anonymous"]}','{}',now(),now(),true);

do $$
declare p public.profiles%rowtype; n integer;
begin
  select count(*) into n from public.profiles where user_id = '03000000-0000-0000-0000-000000000002';
  if n <> 1 then raise exception 'RAHA-030: anonymous user must have exactly one profile'; end if;
  select * into p from public.profiles where user_id = '03000000-0000-0000-0000-000000000002';
  if p.preferred_locale <> 'ar'
     or p.timezone <> 'Asia/Riyadh'
     or p.weekly_goal_days <> 3 then
    raise exception 'RAHA-030: anonymous profile defaults incorrect';
  end if;
end $$;

-- A duplicate trigger invocation must not create a second profile. Re-run the
-- exact guarded insert the trigger performs and confirm the row count is stable.
insert into public.profiles (user_id)
values ('03000000-0000-0000-0000-000000000001')
on conflict (user_id) do nothing;

do $$
declare n integer;
begin
  select count(*) into n from public.profiles where user_id = '03000000-0000-0000-0000-000000000001';
  if n <> 1 then raise exception 'RAHA-030: profile insert is not idempotent'; end if;
end $$;

rollback;
