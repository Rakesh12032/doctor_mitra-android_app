# Doctor Mitra

One Flutter app with role-based panels:

- Patient Panel
- Doctor Panel
- Admin Panel

The app uses one shared data/service structure. It can run in local demo mode, or in internet sync mode with the included REST backend.

## Internet Backend

Run the backend locally:

```bash
cd backend
npm start
```

Deploy `backend/server.js` to any Node hosting service, then build the APK with that public URL:

```bash
flutter build apk --release --dart-define=DOCTOR_MITRA_API_URL=https://your-api-domain.com
```

If `DOCTOR_MITRA_API_URL` is not provided, the app runs with local storage fallback.

## Supabase Backend

Run the SQL in `supabase/doctor_mitra_state.sql` from Supabase Dashboard -> SQL Editor.

Then run the app with your Supabase project URL and anon public key:

```bash
flutter run -d chrome ^
  --dart-define=SUPABASE_URL=https://rcvdwygizotxvxgkbxhk.supabase.co ^
  --dart-define=SUPABASE_ANON_KEY=your-anon-public-key
```

Build APK with Supabase:

```bash
flutter build apk --release ^
  --dart-define=SUPABASE_URL=https://rcvdwygizotxvxgkbxhk.supabase.co ^
  --dart-define=SUPABASE_ANON_KEY=your-anon-public-key
```

Supabase mode stores Patient, Doctor and Admin shared state in Postgres table `doctor_mitra_state`.

Demo credentials:

- Patient OTP: `123456`
- Doctor: `rajeev@doctormitra.in` / `doctor123`
- Admin: `admin@doctormitra.in` / `admin123`

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
