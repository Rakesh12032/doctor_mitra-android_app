const mongoose = require('mongoose');

const UserSchema = new mongoose.Schema(
  {
    phone: {
      type: String,
      required: [true, 'Mobile number is required'],
      unique: true,
      trim: true,
    },
    name: {
      type: String,
      trim: true,
    },
    email: {
      type: String,
      trim: true,
      lowercase: true,
    },
    dob: {
      type: Date,
    },
    gender: {
      type: String,
      enum: ['male', 'female', 'other'],
    },
    profilePhoto: {
      type: String,
      default: '',
    },
    bloodGroup: {
      type: String,
      enum: ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-', ''],
      default: '',
    },
    height: {
      type: Number, // in cm
    },
    weight: {
      type: Number, // in kg
    },
    location: {
      city: { type: String, default: '' },
      address: { type: String, default: '' },
      lat: { type: Number },
      lng: { type: Number },
    },
    familyMembers: [
      {
        name: { type: String, required: true },
        relation: { type: String, required: true },
        age: { type: Number, required: true },
        gender: { type: String, enum: ['male', 'female', 'other'], required: true },
      }
    ],
    knownAllergies: [{ type: String }],
    chronicConditions: [{ type: String }],
    currentMedications: [{ type: String }],
    emergencyContact: {
      name: { type: String, default: '' },
      phone: { type: String, default: '' },
      relation: { type: String, default: '' },
    },
    role: {
      type: String,
      enum: ['patient'],
      default: 'patient',
    },
    fcmToken: {
      type: String,
      default: '',
    },
    isActive: {
      type: Boolean,
      default: true,
    },
    abha: {
      abhaNumber: { type: String, default: '' },
      abhaAddress: { type: String, default: '' },
      isLinked: { type: Boolean, default: false },
      linkedAt: { type: Date }
    },
  },
  {
    timestamps: true,
  }
);

// Virtual property to calculate age automatically
UserSchema.virtual('age').get(function () {
  if (!this.dob) return null;
  const diffMs = Date.now() - this.dob.getTime();
  const ageDate = new Date(diffMs);
  return Math.abs(ageDate.getUTCFullYear() - 1970);
});

module.exports = mongoose.model('User', UserSchema);
