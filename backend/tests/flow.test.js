const assert = require("assert");
const { seedState, applyAction } = require("../lib/doctorMitraCore");

let state = seedState();

function action(type, payload) {
  const result = applyAction(state, { type, payload });
  assert.strictEqual(result.ok, true);
  state = result.state;
  return result;
}

const patientLogin = action("auth.patientOtpLogin", {
  mobile: "9876543210",
  otp: "123456"
});
assert.strictEqual(patientLogin.result.user.role, "patient");
assert.strictEqual(state.currentUserId, null);

const registration = action("auth.registerDoctor", {
  name: "Dr. Backend Test",
  email: "backendtest@doctormitra.in",
  password: "doctor123",
  mobile: "9111111111",
  specialty: "Dentist",
  degree: "BDS",
  registrationNumber: "BRMC-TEST",
  clinicName: "Backend Clinic",
  district: "Patna",
  fee: 500
});
const doctorId = registration.result.doctor.id;
assert.strictEqual(registration.result.doctor.status, "pending");

assert.throws(() => {
  applyAction(state, {
    type: "auth.doctorLogin",
    payload: { email: "backendtest@doctormitra.in", password: "doctor123" }
  });
}, /Registration pending admin approval/);

action("admin.approveDoctor", { doctorId });

const doctorLogin = action("auth.doctorLogin", {
  email: "backendtest@doctormitra.in",
  password: "doctor123"
});
assert.strictEqual(doctorLogin.result.doctor.status, "approved");

const booking = action("booking.create", {
  patientId: "patient-1",
  doctorId,
  type: "clinic",
  date: "20 May 2026",
  time: "10:00",
  symptoms: "Tooth pain"
});
assert.strictEqual(booking.result.booking.status, "pending");

const bookingId = booking.result.booking.id;
action("booking.updateStatus", { bookingId, status: "accepted" });
assert.strictEqual(state.bookings.find((item) => item.id === bookingId).status, "accepted");

action("booking.updateStatus", { bookingId, status: "cancelled" });
assert.strictEqual(state.bookings.find((item) => item.id === bookingId).status, "cancelled");

action("slot.add", { doctorId, slot: "19:00" });
assert(state.doctors.find((item) => item.id === doctorId).slots.includes("19:00"));

action("doctor.savePrescription", {
  bookingId,
  diagnosis: "Dental pain",
  medicines: "Pain relief",
  advice: "Follow up in 3 days"
});
assert.strictEqual(state.bookings.find((item) => item.id === bookingId).status, "completed");
assert.strictEqual(state.prescriptions.length, 1);

console.log("Doctor Mitra backend flow test passed");
