const mongoose = require('mongoose');

const HealthRecordSchema = new mongoose.Schema(
  {
    patient: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: [true, 'Patient reference is required'],
    },
    title: {
      type: String,
      required: [true, 'Document title is required'],
      trim: true,
    },
    category: {
      type: String,
      enum: ['lab', 'prescription', 'radiology', 'vaccination', 'surgery', 'allergy', 'history', 'insurance'],
      required: [true, 'Document category is required'],
    },
    date: {
      type: Date,
      default: Date.now,
    },
    fileUrl: {
      type: String,
      required: [true, 'Document file URL is required'],
    },
    fileType: {
      type: String,
      default: 'pdf',
    },
    notes: {
      type: String,
      default: '',
    },
    sharedWith: [
      {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Doctor',
      }
    ],
  },
  {
    timestamps: true,
  }
);

module.exports = mongoose.model('HealthRecord', HealthRecordSchema);
