# Doctor Mitra Supabase Setup

## 1. Run Database SQL

Open Supabase Dashboard -> SQL Editor -> New query.

Run:

```sql
-- paste everything from:
supabase/doctor_mitra_full_setup.sql
```

This creates:

- Auth profile table
- Patient, doctor and admin role structure
- Doctors, bookings, hospitals, ambulances, health cards, prescriptions, notifications
- Row Level Security policies
- Demo doctors, hospitals, specialties and health tips
- `doctor_mitra_state` bridge table used by the current Flutter MVP

## 2. Auth Settings

Supabase Dashboard -> Authentication -> Providers:

- Enable Email provider for Doctor/Admin login.
- For real Patient phone OTP, enable Phone provider and configure SMS.
- For MVP, patient demo OTP `123456` still works in the app.

## 3. Create Admin User

Supabase Dashboard -> Authentication -> Users -> Add user:

```text
Email: admin@doctormitra.in
Password: Rakesh@12032
Auto Confirm User: ON
```

Then SQL Editor:

```sql
update public.profiles
set role = 'admin', name = 'Doctor Mitra Admin', district = 'Patna'
where email = 'admin@doctormitra.in';
```

## 4. Run App With Supabase

```bash
flutter run -d chrome ^
  --dart-define=SUPABASE_URL=https://rcvdwygizotxvxgkbxhk.supabase.co ^
  --dart-define=SUPABASE_ANON_KEY=your-anon-public-key
```

Build APK:

```bash
flutter build apk --release ^
  --dart-define=SUPABASE_URL=https://rcvdwygizotxvxgkbxhk.supabase.co ^
  --dart-define=SUPABASE_ANON_KEY=your-anon-public-key
```

## Notes

The current Flutter MVP uses `doctor_mitra_state` for connected Patient, Doctor and Admin state. The normalized tables and RLS are ready for the next production step where each screen reads/writes direct database tables.
