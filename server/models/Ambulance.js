const mongoose = require('mongoose');

const AmbulanceSchema = new mongoose.Schema(
  {
    name: {
      type: String,
      required: [true, 'Ambulance service name is required'],
      trim: true,
    },
    type: {
      type: String,
      enum: ['basic', 'advanced', 'icu', 'neonatal', 'air'],
      default: 'basic',
    },
    phone: {
      type: String,
      required: [true, 'Phone number is required'],
    },
    alternatePhone: { type: String, default: '' },
    serviceArea: {
      city: { type: String, required: [true, 'City is required'] },
      district: { type: String, required: [true, 'District is required'] },
      state: { type: String, default: 'Bihar' },
      coverage: { type: String, default: '' }, // e.g. "50km radius from Patna center"
    },
    lat: { type: Number, default: 0 },
    lng: { type: Number, default: 0 },
    isGovernment: { type: Boolean, default: false },
    is24x7: { type: Boolean, default: true },
    charges: {
      basePrice: { type: Number, default: 0 }, // 0 means free (government)
      perKm: { type: Number, default: 0 },
      currency: { type: String, default: 'INR' },
    },
    rating: {
      average: { type: Number, default: 4.0 },
      count: { type: Number, default: 0 },
    },
    isActive: { type: Boolean, default: true },
    features: [{ type: String }], // e.g. "Oxygen", "Ventilator", "Trained EMT"
  },
  { timestamps: true }
);

AmbulanceSchema.index({ 'serviceArea.city': 1, 'serviceArea.district': 1 });

module.exports = mongoose.model('Ambulance', AmbulanceSchema);
