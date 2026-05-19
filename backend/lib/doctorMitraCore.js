const crypto = require("crypto");

const STATE_KEY = "doctor_mitra_state_v2";

function now() {
  return new Date().toISOString();
}

function id(prefix) {
  return `${prefix}-${crypto.randomUUID()}`;
}

function cleanText(value) {
  return String(value || "").trim();
}

function cleanMobile(value) {
  return String(value || "").replace(/\D/g, "");
}

function seedState() {
  const createdAt = now();
  return {
    currentUserId: null,
    maintenanceMode: false,
    updatedAt: createdAt,
    users: [
      {
        id: "admin-1",
        role: "admin",
        name: "Doctor Mitra Admin",
        mobile: "",
        email: "admin@doctormitra.in",
        password: "admin123",
        district: "Patna",
        createdAt
      },
      {
        id: "patient-1",
        role: "patient",
        name: "Rakesh Kumar",
        mobile: "9876543210",
        email: "",
        district: "Patna",
        createdAt
      },
      {
        id: "doctor-user-1",
        role: "doctor",
        name: "Dr. Rajeev Kumar",
        mobile: "9000000001",
        email: "rajeev@doctormitra.in",
        password: "doctor123",
        district: "Patna",
        createdAt
      },
      {
        id: "doctor-user-2",
        role: "doctor",
        name: "Dr. Anjali Singh",
        mobile: "9000000002",
        email: "anjali@doctormitra.in",
        password: "doctor123",
        district: "Patna",
        createdAt
      },
      {
        id: "doctor-user-3",
        role: "doctor",
        name: "Dr. Vikash Jha",
        mobile: "9000000003",
        email: "vikash@doctormitra.in",
        password: "doctor123",
        district: "Patna",
        createdAt
      },
      {
        id: "doctor-user-4",
        role: "doctor",
        name: "Dr. Meena Kumari",
        mobile: "9000000004",
        email: "meena@doctormitra.in",
        password: "doctor123",
        district: "Bhagalpur",
        createdAt
      }
    ],
    doctors: [
      {
        id: "doctor-1",
        userId: "doctor-user-1",
        name: "Dr. Rajeev Kumar",
        specialty: "General Physician",
        degree: "MBBS, MD (Medicine)",
        experience: 15,
        registrationNumber: "BRMC-10234",
        clinicName: "Aarogya Clinic",
        address: "Boring Road, Patna",
        district: "Patna",
        fee: 400,
        onlineFee: 250,
        rating: 4.7,
        reviews: 312,
        status: "approved",
        isOnlineAvailable: true,
        slots: ["09:00", "09:30", "10:00", "10:30", "17:00", "17:30"]
      },
      {
        id: "doctor-2",
        userId: "doctor-user-2",
        name: "Dr. Anjali Singh",
        specialty: "Gynecologist",
        degree: "MBBS, MS (Obs & Gyn)",
        experience: 12,
        registrationNumber: "BRMC-11782",
        clinicName: "Women Care",
        address: "Kankarbagh, Patna",
        district: "Patna",
        fee: 600,
        onlineFee: 400,
        rating: 4.8,
        reviews: 421,
        status: "approved",
        isOnlineAvailable: true,
        slots: ["10:00", "10:30", "11:00", "16:00", "16:30"]
      },
      {
        id: "doctor-3",
        userId: "doctor-user-3",
        name: "Dr. Vikash Jha",
        specialty: "Cardiologist",
        degree: "MBBS, MD, DM (Cardiology)",
        experience: 20,
        registrationNumber: "BRMC-12690",
        clinicName: "Heart Hospital",
        address: "Rajendra Nagar, Patna",
        district: "Patna",
        fee: 800,
        onlineFee: 600,
        rating: 4.9,
        reviews: 512,
        status: "approved",
        isOnlineAvailable: false,
        slots: ["11:00", "11:30", "12:00", "18:00"]
      },
      {
        id: "doctor-4",
        userId: "doctor-user-4",
        name: "Dr. Meena Kumari",
        specialty: "Gynecologist",
        degree: "MBBS, DGO",
        experience: 18,
        registrationNumber: "BRMC-14403",
        clinicName: "Mata Clinic",
        address: "Adampur, Bhagalpur",
        district: "Bhagalpur",
        fee: 600,
        onlineFee: 350,
        rating: 4.8,
        reviews: 312,
        status: "pending",
        isOnlineAvailable: true,
        slots: ["09:00", "09:30", "17:00", "17:30"]
      }
    ],
    bookings: [
      {
        id: "booking-1",
        patientId: "patient-1",
        doctorId: "doctor-1",
        patientName: "Rakesh Kumar",
        patientMobile: "9876543210",
        type: "clinic",
        date: "19 May 2026",
        time: "09:00",
        symptoms: "Fever and body pain",
        fee: 400,
        status: "pending",
        createdAt
      }
    ],
    hospitals: [
      {
        id: "hospital-1",
        name: "Patna City Hospital",
        district: "Patna",
        address: "Bailey Road, Patna",
        phone: "0612-2200001",
        type: "Multispeciality"
      },
      {
        id: "hospital-2",
        name: "Aarogya Hospital",
        district: "Bhagalpur",
        address: "Tilka Manjhi, Bhagalpur",
        phone: "0641-2300002",
        type: "General"
      }
    ],
    ambulances: [
      {
        id: "amb-1",
        name: "Bihar Emergency 102",
        district: "All Bihar",
        phone: "102",
        isAvailable: true
      },
      {
        id: "amb-2",
        name: "Patna Rapid Ambulance",
        district: "Patna",
        phone: "9800000102",
        isAvailable: true
      }
    ],
    healthCards: [
      {
        id: "hc-1",
        userId: "patient-1",
        bloodGroup: "O+",
        allergies: "Dust, Penicillin",
        medications: "None",
        emergencyContact: "9876543211"
      }
    ],
    notifications: [],
    prescriptions: [],
    specialties: [
      "General Physician",
      "Gynecologist",
      "Cardiologist",
      "Dermatologist",
      "Neurologist",
      "Dentist"
    ],
    healthTips: [
      "Drink safe water and keep ORS at home.",
      "Book follow-ups early for chronic conditions.",
      "Use emergency number 102 for ambulance help."
    ]
  };
}

function normalizeState(raw) {
  const seed = seedState();
  const state = raw && typeof raw === "object" ? raw : {};
  const normalized = {
    ...seed,
    ...state,
    users: Array.isArray(state.users) ? state.users : seed.users,
    doctors: Array.isArray(state.doctors) ? state.doctors : seed.doctors,
    bookings: Array.isArray(state.bookings) ? state.bookings : seed.bookings,
    hospitals: Array.isArray(state.hospitals) ? state.hospitals : seed.hospitals,
    ambulances: Array.isArray(state.ambulances) ? state.ambulances : seed.ambulances,
    healthCards: Array.isArray(state.healthCards) ? state.healthCards : seed.healthCards,
    notifications: Array.isArray(state.notifications) ? state.notifications : [],
    prescriptions: Array.isArray(state.prescriptions) ? state.prescriptions : [],
    specialties: Array.isArray(state.specialties) ? state.specialties : seed.specialties,
    healthTips: Array.isArray(state.healthTips) ? state.healthTips : seed.healthTips,
    maintenanceMode: Boolean(state.maintenanceMode)
  };
  normalized.currentUserId = null;
  normalized.updatedAt = state.updatedAt || now();
  return normalized;
}

function validateState(state) {
  const requiredLists = [
    "users",
    "doctors",
    "bookings",
    "hospitals",
    "ambulances",
    "healthCards",
    "notifications",
    "prescriptions",
    "specialties",
    "healthTips"
  ];
  for (const key of requiredLists) {
    if (!Array.isArray(state[key])) {
      throw httpError(400, `Invalid state: ${key} must be an array`);
    }
  }
  return normalizeState(state);
}

function httpError(status, message) {
  const error = new Error(message);
  error.status = status;
  return error;
}

function findUser(state, userId) {
  const user = state.users.find((item) => item.id === userId);
  if (!user) throw httpError(404, "User not found");
  return user;
}

function findDoctor(state, doctorId) {
  const doctor = state.doctors.find((item) => item.id === doctorId);
  if (!doctor) throw httpError(404, "Doctor not found");
  return doctor;
}

function findBooking(state, bookingId) {
  const booking = state.bookings.find((item) => item.id === bookingId);
  if (!booking) throw httpError(404, "Booking not found");
  return booking;
}

function notify(state, userId, title, body) {
  state.notifications.unshift({
    id: id("notification"),
    userId,
    title,
    body,
    createdAt: now()
  });
}

function upsertDoctor(state, doctor) {
  const index = state.doctors.findIndex((item) => item.id === doctor.id);
  if (index === -1) {
    state.doctors.unshift(doctor);
  } else {
    state.doctors[index] = { ...state.doctors[index], ...doctor };
  }
}

function applyAction(inputState, action) {
  const state = normalizeState(inputState);
  const type = action && action.type;
  const payload = (action && action.payload) || {};
  let currentUserId = null;
  let result = null;

  switch (type) {
    case "auth.patientOtpLogin": {
      if (payload.otp !== "123456") throw httpError(401, "Use demo OTP 123456");
      const mobile = cleanMobile(payload.mobile);
      if (mobile.length !== 10) throw httpError(400, "Enter a valid 10 digit mobile number");
      let user = state.users.find((item) => item.role === "patient" && item.mobile === mobile);
      if (!user) {
        user = {
          id: id("patient"),
          role: "patient",
          name: `Patient ${mobile}`,
          mobile,
          email: "",
          district: "Patna",
          createdAt: now()
        };
        state.users.push(user);
        state.healthCards.push({
          id: id("hc"),
          userId: user.id,
          bloodGroup: "Not set",
          allergies: "Not set",
          medications: "Not set",
          emergencyContact: mobile
        });
      }
      currentUserId = user.id;
      result = { user };
      break;
    }

    case "auth.adminLogin": {
      const email = cleanText(payload.email).toLowerCase();
      const user = state.users.find(
        (item) => item.role === "admin" && item.email.toLowerCase() === email && item.password === payload.password
      );
      if (!user) throw httpError(401, "Invalid admin credentials");
      currentUserId = user.id;
      result = { user };
      break;
    }

    case "auth.doctorLogin": {
      const email = cleanText(payload.email).toLowerCase();
      const user = state.users.find(
        (item) => item.role === "doctor" && item.email.toLowerCase() === email && item.password === payload.password
      );
      if (!user) throw httpError(404, "Doctor account not found");
      const doctor = state.doctors.find((item) => item.userId === user.id);
      if (!doctor) throw httpError(404, "Doctor profile missing");
      if (doctor.status !== "approved") {
        throw httpError(403, doctor.status === "pending" ? "Registration pending admin approval" : "Registration rejected by admin");
      }
      currentUserId = user.id;
      result = { user, doctor };
      break;
    }

    case "auth.registerDoctor": {
      const email = cleanText(payload.email).toLowerCase();
      if (!email || !payload.password) throw httpError(400, "Email and password are required");
      if (state.users.some((user) => user.email.toLowerCase() === email)) {
        throw httpError(409, "Email already registered");
      }
      const name = cleanText(payload.name);
      const district = cleanText(payload.district) || "Patna";
      const clinicName = cleanText(payload.clinicName) || "Doctor Mitra Clinic";
      const fee = Number(payload.fee || 0);
      if (!name || fee <= 0) throw httpError(400, "Doctor name and valid fee are required");
      const user = {
        id: id("doctor-user"),
        role: "doctor",
        name,
        mobile: cleanMobile(payload.mobile),
        email,
        password: payload.password,
        district,
        createdAt: now()
      };
      const doctor = {
        id: id("doctor"),
        userId: user.id,
        name,
        specialty: cleanText(payload.specialty) || "General Physician",
        degree: cleanText(payload.degree) || "MBBS",
        experience: Number(payload.experience || 1),
        registrationNumber: cleanText(payload.registrationNumber),
        clinicName,
        address: cleanText(payload.address) || `${clinicName}, ${district}`,
        district,
        fee,
        onlineFee: Number(payload.onlineFee || Math.round(fee * 0.7)),
        rating: Number(payload.rating || 4.5),
        reviews: Number(payload.reviews || 0),
        status: "pending",
        isOnlineAvailable: payload.isOnlineAvailable !== false,
        slots: Array.isArray(payload.slots) && payload.slots.length ? payload.slots : ["10:00", "11:00", "17:00"]
      };
      state.users.push(user);
      state.doctors.push(doctor);
      notify(state, "admin-1", "Doctor approval pending", `${name} submitted registration.`);
      result = { user, doctor };
      break;
    }

    case "auth.logout": {
      currentUserId = null;
      break;
    }

    case "patient.updateProfile": {
      const user = findUser(state, payload.userId);
      if (user.role !== "patient") throw httpError(403, "Only patient profile can be updated here");
      user.name = cleanText(payload.name) || user.name;
      user.mobile = cleanMobile(payload.mobile) || user.mobile;
      user.district = cleanText(payload.district) || user.district;
      result = { user };
      break;
    }

    case "patient.updateHealthCard": {
      const user = findUser(state, payload.userId);
      const card = {
        id: payload.id || id("hc"),
        userId: user.id,
        bloodGroup: cleanText(payload.bloodGroup) || "Not set",
        allergies: cleanText(payload.allergies) || "Not set",
        medications: cleanText(payload.medications) || "Not set",
        emergencyContact: cleanText(payload.emergencyContact) || user.mobile
      };
      const index = state.healthCards.findIndex((item) => item.userId === user.id);
      if (index === -1) state.healthCards.push(card);
      else state.healthCards[index] = card;
      result = { healthCard: card };
      break;
    }

    case "booking.create": {
      const user = findUser(state, payload.patientId);
      const doctor = findDoctor(state, payload.doctorId);
      if (doctor.status !== "approved") throw httpError(403, "Doctor is not approved for bookings");
      const type = payload.type === "online" ? "online" : "clinic";
      if (type === "online" && !doctor.isOnlineAvailable) throw httpError(409, "Doctor is not available online");
      if (!doctor.slots.includes(payload.time)) throw httpError(409, "Selected slot is not available");
      const booking = {
        id: id("booking"),
        patientId: user.id,
        doctorId: doctor.id,
        patientName: user.name,
        patientMobile: user.mobile,
        type,
        date: cleanText(payload.date),
        time: cleanText(payload.time),
        symptoms: cleanText(payload.symptoms) || "Not specified",
        fee: type === "online" ? doctor.onlineFee : doctor.fee,
        status: "pending",
        createdAt: now()
      };
      state.bookings.unshift(booking);
      notify(state, doctor.userId, "New appointment", `${user.name} booked ${doctor.name} for ${booking.date} at ${booking.time}`);
      notify(state, "admin-1", "New booking", `${user.name} booked ${doctor.name}.`);
      result = { booking };
      break;
    }

    case "booking.updateStatus": {
      const allowed = ["pending", "accepted", "rejected", "cancelled", "completed"];
      const status = cleanText(payload.status);
      if (!allowed.includes(status)) throw httpError(400, "Invalid booking status");
      const booking = findBooking(state, payload.bookingId);
      booking.status = status;
      const doctor = findDoctor(state, booking.doctorId);
      notify(state, booking.patientId, `Booking ${status.toUpperCase()}`, `Your appointment with ${doctor.name} is now ${status}.`);
      notify(state, doctor.userId, `Booking ${status.toUpperCase()}`, `${booking.patientName}'s appointment is now ${status}.`);
      result = { booking };
      break;
    }

    case "doctor.update": {
      const doctor = findDoctor(state, payload.doctorId || payload.id);
      const next = { ...doctor, ...payload };
      delete next.doctorId;
      next.fee = Number(next.fee);
      next.onlineFee = Number(next.onlineFee);
      next.experience = Number(next.experience);
      next.reviews = Number(next.reviews);
      next.rating = Number(next.rating);
      next.slots = Array.isArray(next.slots) ? next.slots : doctor.slots;
      upsertDoctor(state, next);
      result = { doctor: next };
      break;
    }

    case "doctor.savePrescription": {
      const booking = findBooking(state, payload.bookingId);
      const prescription = {
        id: id("prescription"),
        bookingId: booking.id,
        doctorId: booking.doctorId,
        patientId: booking.patientId,
        diagnosis: cleanText(payload.diagnosis),
        medicines: cleanText(payload.medicines),
        advice: cleanText(payload.advice),
        createdAt: now()
      };
      state.prescriptions.unshift(prescription);
      booking.status = "completed";
      notify(state, booking.patientId, "Prescription ready", "Your prescription has been added by the doctor.");
      result = { prescription, booking };
      break;
    }

    case "slot.add": {
      const doctor = findDoctor(state, payload.doctorId);
      const slot = cleanText(payload.slot);
      if (slot && !doctor.slots.includes(slot)) doctor.slots = [...doctor.slots, slot].sort();
      result = { doctor };
      break;
    }

    case "slot.remove": {
      const doctor = findDoctor(state, payload.doctorId);
      doctor.slots = doctor.slots.filter((slot) => slot !== payload.slot);
      result = { doctor };
      break;
    }

    case "admin.approveDoctor":
    case "admin.rejectDoctor": {
      const doctor = findDoctor(state, payload.doctorId);
      doctor.status = type === "admin.approveDoctor" ? "approved" : "rejected";
      notify(state, doctor.userId, `Registration ${doctor.status}`, `Your Doctor Mitra profile is ${doctor.status}.`);
      result = { doctor };
      break;
    }

    case "admin.deleteDoctor": {
      const doctor = findDoctor(state, payload.doctorId);
      state.doctors = state.doctors.filter((item) => item.id !== doctor.id);
      state.bookings = state.bookings.filter((booking) => booking.doctorId !== doctor.id);
      result = { doctorId: doctor.id };
      break;
    }

    case "admin.upsertDoctor": {
      const doctor = { ...payload.doctor };
      if (!doctor.id) doctor.id = id("doctor");
      if (!doctor.userId) doctor.userId = id("doctor-user");
      doctor.fee = Number(doctor.fee || 0);
      doctor.onlineFee = Number(doctor.onlineFee || Math.round(doctor.fee * 0.7));
      doctor.experience = Number(doctor.experience || 1);
      doctor.reviews = Number(doctor.reviews || 0);
      doctor.rating = Number(doctor.rating || 4.5);
      doctor.status = doctor.status || "approved";
      doctor.isOnlineAvailable = doctor.isOnlineAvailable !== false;
      doctor.slots = Array.isArray(doctor.slots) ? doctor.slots : ["10:00", "11:00", "17:00"];
      upsertDoctor(state, doctor);
      result = { doctor };
      break;
    }

    case "admin.addSpecialty": {
      const specialty = cleanText(payload.specialty);
      if (specialty && !state.specialties.includes(specialty)) state.specialties.push(specialty);
      result = { specialties: state.specialties };
      break;
    }

    case "admin.deleteSpecialty": {
      const specialty = cleanText(payload.specialty);
      state.specialties = state.specialties.filter((s) => s !== specialty);
      result = { specialties: state.specialties };
      break;
    }

    case "admin.addHealthTip": {
      const tip = cleanText(payload.tip);
      if (tip) state.healthTips.unshift(tip);
      result = { healthTips: state.healthTips };
      break;
    }

    case "admin.deleteHealthTip": {
      const tip = cleanText(payload.tip);
      state.healthTips = state.healthTips.filter((t) => t !== tip);
      result = { healthTips: state.healthTips };
      break;
    }

    case "admin.setMaintenanceMode": {
      state.maintenanceMode = Boolean(payload.value);
      result = { maintenanceMode: state.maintenanceMode };
      break;
    }

    case "hospital.add": {
      const hospital = {
        id: payload.id || id("hospital"),
        name: cleanText(payload.name),
        district: cleanText(payload.district) || "Patna",
        address: cleanText(payload.address),
        phone: cleanText(payload.phone),
        type: cleanText(payload.type) || "General"
      };
      if (!hospital.name) throw httpError(400, "Hospital name is required");
      const index = state.hospitals.findIndex((item) => item.id === hospital.id);
      if (index === -1) state.hospitals.unshift(hospital);
      else state.hospitals[index] = hospital;
      result = { hospital };
      break;
    }

    case "hospital.delete": {
      state.hospitals = state.hospitals.filter((hospital) => hospital.id !== payload.id);
      result = { id: payload.id };
      break;
    }

    case "ambulance.add": {
      const ambulance = {
        id: payload.id || id("amb"),
        name: cleanText(payload.name),
        district: cleanText(payload.district) || "Patna",
        phone: cleanText(payload.phone),
        isAvailable: payload.isAvailable !== false
      };
      if (!ambulance.name || !ambulance.phone) throw httpError(400, "Ambulance name and phone are required");
      const index = state.ambulances.findIndex((item) => item.id === ambulance.id);
      if (index === -1) state.ambulances.unshift(ambulance);
      else state.ambulances[index] = ambulance;
      result = { ambulance };
      break;
    }

    case "ambulance.delete": {
      state.ambulances = state.ambulances.filter((amb) => amb.id !== payload.id);
      result = { id: payload.id };
      break;
    }

    default:
      throw httpError(400, `Unknown action: ${type || "missing"}`);
  }

  state.currentUserId = null;
  state.updatedAt = now();
  return { ok: true, state, currentUserId, result };
}

async function readJsonBody(req) {
  if (req.body && typeof req.body === "object") return req.body;
  if (typeof req.body === "string") return JSON.parse(req.body || "{}");

  return new Promise((resolve, reject) => {
    let body = "";
    req.on("data", (chunk) => {
      body += chunk;
      if (body.length > 10_000_000) {
        reject(httpError(413, "Payload too large"));
        req.destroy();
      }
    });
    req.on("end", () => {
      try {
        resolve(JSON.parse(body || "{}"));
      } catch (error) {
        reject(httpError(400, "Invalid JSON body"));
      }
    });
    req.on("error", reject);
  });
}

function sendJson(res, status, payload) {
  res.writeHead(status, {
    "Content-Type": "application/json; charset=utf-8",
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Methods": "GET, PUT, POST, DELETE, OPTIONS",
    "Access-Control-Allow-Headers": "Content-Type, Authorization"
  });
  res.end(JSON.stringify(payload));
}

function sendError(res, error) {
  sendJson(res, error.status || 500, { ok: false, error: error.message || "Server error" });
}

module.exports = {
  STATE_KEY,
  now,
  seedState,
  normalizeState,
  validateState,
  applyAction,
  readJsonBody,
  sendJson,
  sendError
};
