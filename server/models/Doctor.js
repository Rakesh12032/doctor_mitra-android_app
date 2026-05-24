const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

const DoctorSchema = new mongoose.Schema(
  {
    name: {
      type: String,
      required: [true, 'Name is required'],
      trim: true,
    },
    phone: {
      type: String,
      required: [true, 'Phone number is required'],
      unique: true,
      trim: true,
    },
    email: {
      type: String,
      required: [true, 'Email is required'],
      unique: true,
      trim: true,
      lowercase: true,
    },
    password: {
      type: String,
      required: [true, 'Password is required'],
      select: false, // Don't return password in queries by default
    },
    speciality: {
      type: String,
      required: [true, 'Primary specialty is required'],
      trim: true,
    },
    subSpecialities: [{ type: String }],
    qualification: [
      {
        degree: { type: String, required: true },
        institute: { type: String, required: true },
        year: { type: Number, required: true },
      }
    ],
    experience: {
      type: Number,
      required: [true, 'Experience years are required'],
    },
    registrationNumber: {
      type: String,
      required: [true, 'MCI/State Medical Council registration number is required'],
      unique: true,
      trim: true,
    },
    clinics: [
      {
        name: { type: String, required: true },
        address: { type: String, required: true },
        city: { type: String, required: true },
        lat: { type: Number, required: true },
        lng: { type: Number, required: true },
        timings: { type: String, required: true }, // e.g. "Mon-Sat 10AM-2PM, 5PM-8PM"
      }
    ],
    consultationFees: {
      clinic: { type: Number, default: 0 },
      video: { type: Number, default: 0 },
      phone: { type: Number, default: 0 },
    },
    languages: [{ type: String }], // e.g. "English", "Hindi", "Bhojpuri", "Maithili"
    about: {
      type: String,
      trim: true,
    },
    profilePhoto: {
      type: String,
      default: '',
    },
    documents: [
      {
        type: { type: String, required: true },
        url: { type: String, required: true },
      }
    ],
    bankDetails: {
      accountNo: { type: String, default: '' },
      ifsc: { type: String, default: '' },
      name: { type: String, default: '' },
    },
    isVerified: {
      type: Boolean,
      default: false,
    },
    isApproved: {
      type: Boolean,
      default: false, // Requires admin verification
    },
    isActive: {
      type: Boolean,
      default: true,
    },
    role: {
      type: String,
      enum: ['doctor'],
      default: 'doctor',
    },
    rating: {
      average: { type: Number, default: 4.5 },
      count: { type: Number, default: 0 },
    },
    availableDays: {
      type: [String],
      default: ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'],
    },
    slotDuration: {
      type: Number,
      default: 15, // in minutes
    },
    breakStart: { type: String, default: '14:00' }, // 24-hr format
    breakEnd: { type: String, default: '15:00' },
    fcmToken: {
      type: String,
      default: '',
    },
  },
  {
    timestamps: true,
  }
);

// Hash password before saving
DoctorSchema.pre('save', async function (next) {
  if (!this.isModified('password')) {
    return next();
  }
  const salt = await bcrypt.genSalt(10);
  this.password = await bcrypt.hash(this.password, salt);
  next();
});

// Compare password method
DoctorSchema.methods.matchPassword = async function (enteredPassword) {
  return await bcrypt.compare(enteredPassword, this.password);
};

module.exports = mongoose.model('Doctor', DoctorSchema);
