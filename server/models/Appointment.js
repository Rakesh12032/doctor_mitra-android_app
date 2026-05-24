const mongoose = require('mongoose');

const AppointmentSchema = new mongoose.Schema(
  {
    patient: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: [true, 'Patient reference is required'],
    },
    doctor: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Doctor',
      required: [true, 'Doctor reference is required'],
    },
    appointmentType: {
      type: String,
      enum: ['clinic', 'video', 'phone'],
      required: [true, 'Appointment type is required'],
    },
    date: {
      type: Date,
      required: [true, 'Appointment date is required'],
    },
    timeSlot: {
      type: String, // e.g. "10:30 AM" or "16:15"
      required: [true, 'Appointment time slot is required'],
    },
    duration: {
      type: Number,
      default: 15, // in minutes
    },
    status: {
      type: String,
      enum: ['pending', 'confirmed', 'completed', 'cancelled', 'no-show'],
      default: 'pending',
    },
    symptoms: {
      type: String,
      maxlength: [200, 'Symptoms cannot exceed 200 characters'],
      trim: true,
    },
    notes: {
      type: String,
      trim: true,
    },
    documents: [
      {
        url: { type: String, required: true },
        name: { type: String, default: 'Medical Document' },
        uploadedAt: { type: Date, default: Date.now },
      }
    ],
    payment: {
      amount: { type: Number, required: true },
      method: { type: String, enum: ['UPI', 'card', 'netbanking', 'cash_at_clinic'], default: 'cash_at_clinic' },
      status: { type: String, enum: ['pending', 'successful', 'failed', 'refunded'], default: 'pending' },
      transactionId: { type: String },
      razorpayOrderId: { type: String },
      razorpaySignature: { type: String },
    },
    prescription: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Prescription',
    },
    meetingLink: {
      type: String, // Agora channel/token URL
      default: '',
    },
    cancelReason: {
      type: String,
      default: '',
    },
    rescheduledFrom: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Appointment',
    },
    patientDetails: {
      name: { type: String },
      age: { type: Number },
      gender: { type: String },
      relation: { type: String, default: 'self' },
    },
  },
  {
    timestamps: true,
  }
);

// Indexes for fast searching of patient/doctor schedules
AppointmentSchema.index({ patient: 1, date: -1 });
AppointmentSchema.index({ doctor: 1, date: -1 });
AppointmentSchema.index({ doctor: 1, date: 1, timeSlot: 1 }, { unique: true }); // Prevent double bookings!

module.exports = mongoose.model('Appointment', AppointmentSchema);
