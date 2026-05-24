const mongoose = require('mongoose');

const HospitalSchema = new mongoose.Schema(
  {
    name: {
      type: String,
      required: [true, 'Hospital name is required'],
      trim: true,
    },
    type: {
      type: String,
      enum: ['government', 'private', 'clinic', 'nursing_home', 'medical_college'],
      default: 'private',
    },
    address: {
      street: { type: String, default: '' },
      city: { type: String, required: [true, 'City is required'] },
      district: { type: String, required: [true, 'District is required'] },
      state: { type: String, default: 'Bihar' },
      pincode: { type: String, default: '' },
    },
    lat: { type: Number, default: 0 },
    lng: { type: Number, default: 0 },
    phone: { type: String, default: '' },
    emergencyPhone: { type: String, default: '' },
    specialities: [{ type: String }],
    facilities: [{ type: String }], // e.g. ICU, NICU, CT Scan, MRI, Blood Bank
    beds: {
      total: { type: Number, default: 0 },
      available: { type: Number, default: 0 },
    },
    rating: {
      average: { type: Number, default: 4.0 },
      count: { type: Number, default: 0 },
    },
    isActive: { type: Boolean, default: true },
    imageUrl: { type: String, default: '' },
    website: { type: String, default: '' },
    timings: { type: String, default: '24x7' }, // e.g. "Mon-Sat 8AM-10PM" or "24x7"
  },
  { timestamps: true }
);

// Index for geo-queries and text search
HospitalSchema.index({ 'address.city': 1, 'address.district': 1 });
HospitalSchema.index({ name: 'text', 'address.city': 'text' });

module.exports = mongoose.model('Hospital', HospitalSchema);
