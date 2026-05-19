-- Doctor Mitra MVP Supabase backend bridge.
-- Prefer running supabase/doctor_mitra_full_setup.sql for database + auth + RLS.
-- Run this smaller file only if you want the JSON-state bridge table.
--
-- This creates one shared JSON state row for the current Flutter MVP.
-- It keeps Patient, Doctor and Admin panels connected through Supabase Postgres.
-- For production, replace these demo policies with stricter role-based RLS.

create table if not exists public.doctor_mitra_state (
  id text primary key,
  state jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);

alter table public.doctor_mitra_state enable row level security;

drop policy if exists "doctor_mitra_state_select" on public.doctor_mitra_state;
drop policy if exists "doctor_mitra_state_insert" on public.doctor_mitra_state;
drop policy if exists "doctor_mitra_state_update" on public.doctor_mitra_state;

create policy "doctor_mitra_state_select"
on public.doctor_mitra_state
for select
to anon, authenticated
using (id = 'singleton');

create policy "doctor_mitra_state_insert"
on public.doctor_mitra_state
for insert
to anon, authenticated
with check (id = 'singleton');

create policy "doctor_mitra_state_update"
on public.doctor_mitra_state
for update
to anon, authenticated
using (id = 'singleton')
with check (id = 'singleton');

insert into public.doctor_mitra_state (id, state)
values ('singleton', '{}'::jsonb)
on conflict (id) do nothing;
