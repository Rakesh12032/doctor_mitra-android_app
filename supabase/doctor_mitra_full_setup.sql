-- Doctor Mitra full Supabase setup.
-- Run this in Supabase Dashboard -> SQL Editor.
--
-- What this creates:
-- 1. Supabase Auth profile table with patient/doctor/admin roles.
-- 2. Normalized Doctor Mitra database tables.
-- 3. Row Level Security policies for Patient, Doctor and Admin access.
-- 4. Demo specialties, hospitals, ambulances, health tips and approved doctors.
-- 5. The JSON state bridge table used by the current Flutter MVP.

create extension if not exists pgcrypto;

do $$ begin
  create type public.app_role as enum ('patient', 'doctor', 'admin');
exception when duplicate_object then null;
end $$;

do $$ begin
  create type public.doctor_status as enum ('pending', 'approved', 'rejected');
exception when duplicate_object then null;
end $$;

do $$ begin
  create type public.booking_type as enum ('clinic', 'online');
exception when duplicate_object then null;
end $$;

do $$ begin
  create type public.booking_status as enum ('pending', 'accepted', 'rejected', 'cancelled', 'completed');
exception when duplicate_object then null;
end $$;

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  role public.app_role not null default 'patient',
  name text not null default 'Doctor Mitra User',
  mobile text not null default '',
  email text not null default '',
  district text not null default 'Patna',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.specialties (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  created_at timestamptz not null default now()
);

create table if not exists public.doctors (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references public.profiles(id) on delete set null,
  name text not null,
  specialty text not null,
  degree text not null,
  experience int not null default 1,
  registration_number text not null unique,
  clinic_name text not null,
  address text not null,
  district text not null default 'Patna',
  fee numeric(10,2) not null default 0,
  online_fee numeric(10,2) not null default 0,
  rating numeric(3,2) not null default 4.5,
  reviews int not null default 0,
  status public.doctor_status not null default 'pending',
  is_online_available boolean not null default true,
  slots text[] not null default array['10:00','11:00','17:00'],
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.hospitals (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  district text not null default 'Patna',
  address text not null,
  phone text not null,
  type text not null default 'General',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.ambulance_providers (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  district text not null default 'Patna',
  phone text not null,
  is_available boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.health_cards (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  blood_group text not null default 'Not set',
  allergies text not null default 'Not set',
  medications text not null default 'Not set',
  emergency_contact text not null default '',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (user_id)
);

create table if not exists public.bookings (
  id uuid primary key default gen_random_uuid(),
  patient_id uuid not null references public.profiles(id) on delete cascade,
  doctor_id uuid not null references public.doctors(id) on delete cascade,
  patient_name text not null,
  patient_mobile text not null,
  type public.booking_type not null default 'clinic',
  appointment_date date not null,
  appointment_time text not null,
  symptoms text not null default 'Not specified',
  fee numeric(10,2) not null default 0,
  status public.booking_status not null default 'pending',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.notifications (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  title text not null,
  body text not null,
  is_read boolean not null default false,
  created_at timestamptz not null default now()
);

create table if not exists public.prescriptions (
  id uuid primary key default gen_random_uuid(),
  booking_id uuid not null references public.bookings(id) on delete cascade,
  doctor_id uuid not null references public.doctors(id) on delete cascade,
  patient_id uuid not null references public.profiles(id) on delete cascade,
  diagnosis text not null,
  medicines text not null,
  advice text not null,
  created_at timestamptz not null default now()
);

create table if not exists public.health_tips (
  id uuid primary key default gen_random_uuid(),
  tip text not null unique,
  created_at timestamptz not null default now()
);

create table if not exists public.app_settings (
  key text primary key,
  value jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);

-- Current Flutter MVP bridge table.
create table if not exists public.doctor_mitra_state (
  id text primary key,
  state jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);

drop trigger if exists profiles_set_updated_at on public.profiles;
create trigger profiles_set_updated_at before update on public.profiles
for each row execute function public.set_updated_at();

drop trigger if exists doctors_set_updated_at on public.doctors;
create trigger doctors_set_updated_at before update on public.doctors
for each row execute function public.set_updated_at();

drop trigger if exists hospitals_set_updated_at on public.hospitals;
create trigger hospitals_set_updated_at before update on public.hospitals
for each row execute function public.set_updated_at();

drop trigger if exists ambulance_providers_set_updated_at on public.ambulance_providers;
create trigger ambulance_providers_set_updated_at before update on public.ambulance_providers
for each row execute function public.set_updated_at();

drop trigger if exists health_cards_set_updated_at on public.health_cards;
create trigger health_cards_set_updated_at before update on public.health_cards
for each row execute function public.set_updated_at();

drop trigger if exists bookings_set_updated_at on public.bookings;
create trigger bookings_set_updated_at before update on public.bookings
for each row execute function public.set_updated_at();

create or replace function public.handle_new_auth_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, role, name, mobile, email, district)
  values (
    new.id,
    coalesce((new.raw_user_meta_data ->> 'role')::public.app_role, 'patient'),
    coalesce(new.raw_user_meta_data ->> 'name', split_part(new.email, '@', 1), 'Doctor Mitra User'),
    coalesce(new.phone, new.raw_user_meta_data ->> 'mobile', ''),
    coalesce(new.email, ''),
    coalesce(new.raw_user_meta_data ->> 'district', 'Patna')
  )
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
after insert on auth.users
for each row execute function public.handle_new_auth_user();

create or replace function public.is_admin()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1 from public.profiles
    where id = auth.uid() and role = 'admin'
  );
$$;

create or replace function public.is_booking_doctor(target_doctor_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1 from public.doctors
    where id = target_doctor_id and user_id = auth.uid()
  );
$$;

alter table public.profiles enable row level security;
alter table public.specialties enable row level security;
alter table public.doctors enable row level security;
alter table public.hospitals enable row level security;
alter table public.ambulance_providers enable row level security;
alter table public.health_cards enable row level security;
alter table public.bookings enable row level security;
alter table public.notifications enable row level security;
alter table public.prescriptions enable row level security;
alter table public.health_tips enable row level security;
alter table public.app_settings enable row level security;
alter table public.doctor_mitra_state enable row level security;

drop policy if exists profiles_select on public.profiles;
create policy profiles_select on public.profiles
for select to authenticated
using (id = auth.uid() or public.is_admin());

drop policy if exists profiles_update on public.profiles;
create policy profiles_update on public.profiles
for update to authenticated
using (id = auth.uid() or public.is_admin())
with check (id = auth.uid() or public.is_admin());

drop policy if exists public_specialties_read on public.specialties;
create policy public_specialties_read on public.specialties
for select to anon, authenticated
using (true);

drop policy if exists admin_specialties_write on public.specialties;
create policy admin_specialties_write on public.specialties
for all to authenticated
using (public.is_admin())
with check (public.is_admin());

drop policy if exists doctors_read on public.doctors;
create policy doctors_read on public.doctors
for select to anon, authenticated
using (status = 'approved' or user_id = auth.uid() or public.is_admin());

drop policy if exists doctors_insert on public.doctors;
create policy doctors_insert on public.doctors
for insert to authenticated
with check (user_id = auth.uid() or public.is_admin());

drop policy if exists doctors_update on public.doctors;
create policy doctors_update on public.doctors
for update to authenticated
using (user_id = auth.uid() or public.is_admin())
with check (user_id = auth.uid() or public.is_admin());

drop policy if exists doctors_delete on public.doctors;
create policy doctors_delete on public.doctors
for delete to authenticated
using (public.is_admin());

drop policy if exists hospitals_read on public.hospitals;
create policy hospitals_read on public.hospitals
for select to anon, authenticated
using (true);

drop policy if exists hospitals_admin_write on public.hospitals;
create policy hospitals_admin_write on public.hospitals
for all to authenticated
using (public.is_admin())
with check (public.is_admin());

drop policy if exists ambulance_read on public.ambulance_providers;
create policy ambulance_read on public.ambulance_providers
for select to anon, authenticated
using (true);

drop policy if exists ambulance_admin_write on public.ambulance_providers;
create policy ambulance_admin_write on public.ambulance_providers
for all to authenticated
using (public.is_admin())
with check (public.is_admin());

drop policy if exists health_cards_owner_read on public.health_cards;
create policy health_cards_owner_read on public.health_cards
for select to authenticated
using (user_id = auth.uid() or public.is_admin());

drop policy if exists health_cards_owner_write on public.health_cards;
create policy health_cards_owner_write on public.health_cards
for all to authenticated
using (user_id = auth.uid() or public.is_admin())
with check (user_id = auth.uid() or public.is_admin());

drop policy if exists bookings_read on public.bookings;
create policy bookings_read on public.bookings
for select to authenticated
using (
  patient_id = auth.uid()
  or public.is_booking_doctor(doctor_id)
  or public.is_admin()
);

drop policy if exists bookings_patient_insert on public.bookings;
create policy bookings_patient_insert on public.bookings
for insert to authenticated
with check (patient_id = auth.uid());

drop policy if exists bookings_update on public.bookings;
create policy bookings_update on public.bookings
for update to authenticated
using (
  patient_id = auth.uid()
  or public.is_booking_doctor(doctor_id)
  or public.is_admin()
)
with check (
  patient_id = auth.uid()
  or public.is_booking_doctor(doctor_id)
  or public.is_admin()
);

drop policy if exists notifications_owner_read on public.notifications;
create policy notifications_owner_read on public.notifications
for select to authenticated
using (user_id = auth.uid() or public.is_admin());

drop policy if exists notifications_owner_update on public.notifications;
create policy notifications_owner_update on public.notifications
for update to authenticated
using (user_id = auth.uid() or public.is_admin())
with check (user_id = auth.uid() or public.is_admin());

drop policy if exists notifications_system_insert on public.notifications;
create policy notifications_system_insert on public.notifications
for insert to authenticated
with check (public.is_admin() or user_id = auth.uid());

drop policy if exists prescriptions_read on public.prescriptions;
create policy prescriptions_read on public.prescriptions
for select to authenticated
using (
  patient_id = auth.uid()
  or public.is_booking_doctor(doctor_id)
  or public.is_admin()
);

drop policy if exists prescriptions_doctor_insert on public.prescriptions;
create policy prescriptions_doctor_insert on public.prescriptions
for insert to authenticated
with check (public.is_booking_doctor(doctor_id) or public.is_admin());

drop policy if exists health_tips_read on public.health_tips;
create policy health_tips_read on public.health_tips
for select to anon, authenticated
using (true);

drop policy if exists health_tips_admin_write on public.health_tips;
create policy health_tips_admin_write on public.health_tips
for all to authenticated
using (public.is_admin())
with check (public.is_admin());

drop policy if exists app_settings_admin_read on public.app_settings;
create policy app_settings_admin_read on public.app_settings
for select to authenticated
using (public.is_admin());

drop policy if exists app_settings_admin_write on public.app_settings;
create policy app_settings_admin_write on public.app_settings
for all to authenticated
using (public.is_admin())
with check (public.is_admin());

-- Bridge policies for the current Flutter MVP.
-- Demo-friendly: anon can read/write this singleton state row. Tighten this before production.
drop policy if exists doctor_mitra_state_select on public.doctor_mitra_state;
create policy doctor_mitra_state_select on public.doctor_mitra_state
for select to anon, authenticated
using (id = 'singleton');

drop policy if exists doctor_mitra_state_insert on public.doctor_mitra_state;
create policy doctor_mitra_state_insert on public.doctor_mitra_state
for insert to anon, authenticated
with check (id = 'singleton');

drop policy if exists doctor_mitra_state_update on public.doctor_mitra_state;
create policy doctor_mitra_state_update on public.doctor_mitra_state
for update to anon, authenticated
using (id = 'singleton')
with check (id = 'singleton');

insert into public.specialties (name) values
  ('General Physician'),
  ('Gynecologist'),
  ('Cardiologist'),
  ('Dermatologist'),
  ('Neurologist'),
  ('Dentist')
on conflict (name) do nothing;

insert into public.hospitals (name, district, address, phone, type) values
  ('Patna City Hospital', 'Patna', 'Bailey Road, Patna', '0612-2200001', 'Multispeciality'),
  ('Aarogya Hospital', 'Bhagalpur', 'Tilka Manjhi, Bhagalpur', '0641-2300002', 'General')
on conflict do nothing;

insert into public.ambulance_providers (name, district, phone, is_available) values
  ('Bihar Emergency 102', 'All Bihar', '102', true),
  ('Patna Rapid Ambulance', 'Patna', '9800000102', true)
on conflict do nothing;

insert into public.health_tips (tip) values
  ('Drink safe water and keep ORS at home.'),
  ('Book follow-ups early for chronic conditions.'),
  ('Use emergency number 102 for ambulance help.')
on conflict (tip) do nothing;

insert into public.app_settings (key, value) values
  ('maintenance_mode', '{"enabled": false}'::jsonb)
on conflict (key) do nothing;

insert into public.doctors (
  name, specialty, degree, experience, registration_number, clinic_name,
  address, district, fee, online_fee, rating, reviews, status, is_online_available, slots
) values
  ('Dr. Rajeev Kumar', 'General Physician', 'MBBS, MD (Medicine)', 15, 'BRMC-10234', 'Aarogya Clinic', 'Boring Road, Patna', 'Patna', 400, 250, 4.7, 312, 'approved', true, array['09:00','09:30','10:00','10:30','17:00','17:30']),
  ('Dr. Anjali Singh', 'Gynecologist', 'MBBS, MS (Obs & Gyn)', 12, 'BRMC-11782', 'Women Care', 'Kankarbagh, Patna', 'Patna', 600, 400, 4.8, 421, 'approved', true, array['10:00','10:30','11:00','16:00','16:30']),
  ('Dr. Vikash Jha', 'Cardiologist', 'MBBS, MD, DM (Cardiology)', 20, 'BRMC-12690', 'Heart Hospital', 'Rajendra Nagar, Patna', 'Patna', 800, 600, 4.9, 512, 'approved', false, array['11:00','11:30','12:00','18:00']),
  ('Dr. Meena Kumari', 'Gynecologist', 'MBBS, DGO', 18, 'BRMC-14403', 'Mata Clinic', 'Adampur, Bhagalpur', 'Bhagalpur', 600, 350, 4.8, 312, 'pending', true, array['09:00','09:30','17:00','17:30'])
on conflict (registration_number) do nothing;

insert into public.doctor_mitra_state (id, state)
values ('singleton', '{}'::jsonb)
on conflict (id) do nothing;

-- After creating an admin in Authentication -> Users, run this line with the admin email:
-- update public.profiles set role = 'admin', name = 'Doctor Mitra Admin' where email = 'admin@doctormitra.in';
