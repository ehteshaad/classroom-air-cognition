-- Classroom Air & Cognition Study: Supabase schema
-- Run in Supabase Dashboard > SQL Editor.
-- The browser uses only the publishable key. Never expose service_role/secret keys.

create extension if not exists pgcrypto;

create table if not exists public.assessment_sessions (
  id uuid primary key,
  participant_id text not null check (length(trim(participant_id)) between 1 and 80),
  classroom text not null,
  assessment_date date not null,
  assessment text not null check (assessment in ('pre','post')),
  start_time time,
  session_code text,
  client_started_at timestamptz,
  questionnaire jsonb not null default '{}'::jsonb,
  pvt jsonb not null default '{}'::jsonb,
  stroop jsonb not null default '{}'::jsonb,
  completed_at timestamptz not null default now(),
  schema_version integer not null default 1,
  inserted_at timestamptz not null default now()
);

create index if not exists assessment_sessions_participant_idx
  on public.assessment_sessions (participant_id);
create index if not exists assessment_sessions_date_class_idx
  on public.assessment_sessions (assessment_date, classroom);
create index if not exists assessment_sessions_assessment_idx
  on public.assessment_sessions (assessment);

alter table public.assessment_sessions enable row level security;

-- Start with least privilege.
revoke all on table public.assessment_sessions from anon, authenticated;
grant insert on table public.assessment_sessions to anon;
grant select on table public.assessment_sessions to authenticated;

drop policy if exists "Public participants may submit an assessment" on public.assessment_sessions;
create policy "Public participants may submit an assessment"
  on public.assessment_sessions
  for insert
  to anon
  with check (
    length(trim(participant_id)) between 1 and 80
    and assessment in ('pre','post')
  );

drop policy if exists "Authenticated researchers may read assessments" on public.assessment_sessions;
create policy "Authenticated researchers may read assessments"
  on public.assessment_sessions
  for select
  to authenticated
  using (true);

-- No anonymous SELECT/UPDATE/DELETE policy is created.
-- Disable public sign-ups in Supabase Auth. Create researcher accounts yourself
-- from the Supabase dashboard. Any authenticated user in this project can read
-- all study records, so only create accounts for authorized research-team members.
