const mongoose = require('mongoose');

const PrescriptionSchema = new mongoose.Schema(
  {
    appointment: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Appointment',
      required: [true, 'Appointment reference is required'],
    },
    doctor: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Doctor',
      required: [true, 'Doctor reference is required'],
    },
    patient: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: [true, 'Patient reference is required'],
    },
    symptoms: {
      type: String,
      trim: true,
    },
    diagnosis: {
      type: String,
      trim: true,
    },
    medicines: [
      {
        name: { type: String, required: true },
        dosage: { type: String, required: true }, // e.g. "500mg" or "1 tablet"
        route: { type: String, enum: ['oral', 'topical', 'injection', 'inhalation', 'drops'], default: 'oral' },
        frequency: { type: String, enum: ['OD', 'BD', 'TDS', 'QID', 'SOS'], required: true }, // OD = Once a day, etc.
        duration: { type: String, required: true }, // e.g. "5 days" or "1 week"
        beforeFood: { type: Boolean, default: false },
        instructions: { type: String, default: '' },
      }
    ],
    labTests: [{ type: String }], // List of lab tests to get done
    advice: {
      type: String,
      default: '',
    },
    followUpDate: {
      type: Date,
    },
    pdfUrl: {
      type: String, // Cloudinary PDF url
      default: '',
    },
  },
  {
    timestamps: true,
  }
);

module.exports = mongoose.model('Prescription', PrescriptionSchema);
