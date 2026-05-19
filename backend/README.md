# Doctor Mitra Internet API

This is the shared backend for the single Doctor Mitra app.

It stores one connected state used by:
- Patient Panel
- Doctor Panel
- Admin Panel

The app now uses backend actions for real shared flow. Patient, doctor and admin changes are applied on the server first, then the updated shared state is returned to the app.

## Run Locally

```bash
cd backend
npm start
```

API URL:

```text
http://localhost:8080
```

Health check:

```text
GET /health
```

State API:

```text
GET /api/state
PUT /api/state
POST /api/reset
```

Action API:

```text
POST /api/actions
```

Supported action types:

```text
auth.patientOtpLogin
auth.adminLogin
auth.doctorLogin
auth.registerDoctor
auth.logout
patient.updateProfile
patient.updateHealthCard
booking.create
booking.updateStatus
doctor.update
doctor.savePrescription
slot.add
slot.remove
admin.approveDoctor
admin.rejectDoctor
admin.deleteDoctor
admin.upsertDoctor
admin.addSpecialty
admin.addHealthTip
admin.setMaintenanceMode
hospital.add
hospital.delete
```

Example:

```bash
curl -X POST http://localhost:8080/api/actions \
  -H "Content-Type: application/json" \
  -d "{\"type\":\"booking.updateStatus\",\"payload\":{\"bookingId\":\"booking-1\",\"status\":\"accepted\"}}"
```

## Test Backend Flow

```bash
cd backend
npm test
```

This verifies doctor registration approval, doctor login, patient booking, booking status updates, slots and prescription flow.

## Vercel Data Persistence

For real internet usage, add Upstash Redis env vars in Vercel:

```text
UPSTASH_REDIS_REST_URL
UPSTASH_REDIS_REST_TOKEN
```

Without these env vars, Vercel serverless functions use memory fallback and data can reset between cold starts. Local development uses `backend/data/doctor_mitra_state.json`.

## Build APK With Internet API

Use your deployed backend URL:

```bash
flutter build apk --release --dart-define=DOCTOR_MITRA_API_URL=https://your-api-domain.com
```

Without `DOCTOR_MITRA_API_URL`, the app runs in local demo mode.
With `DOCTOR_MITRA_API_URL`, the app syncs patient, doctor and admin data through the internet API.
