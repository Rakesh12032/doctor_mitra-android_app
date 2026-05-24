const mongoose = require('mongoose');

const MedicineSchema = new mongoose.Schema(
  {
    name: {
      type: String,
      required: [true, 'Medicine name is required'],
      unique: true,
      trim: true,
    },
    genericName: {
      type: String,
      required: [true, 'Generic chemical name is required'],
      trim: true,
    },
    manufacturer: {
      type: String,
      required: [true, 'Manufacturer is required'],
      trim: true,
    },
    price: {
      type: Number,
      required: [true, 'Retail price is required'],
    },
    composition: {
      type: String,
      default: '',
    },
    uses: [{ type: String }],
    sideEffects: [{ type: String }],
    dosage: {
      type: String,
      default: 'As directed by physician',
    },
    category: {
      type: String,
      default: 'General',
    },
    isAvailable: {
      type: Boolean,
      default: true,
    },
  },
  {
    timestamps: true,
  }
);

MedicineSchema.index({ name: 'text', genericName: 'text', uses: 'text' });

module.exports = mongoose.model('Medicine', MedicineSchema);
