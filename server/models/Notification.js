const mongoose = require('mongoose');

const NotificationSchema = new mongoose.Schema(
  {
    user: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: [true, 'User reference is required'],
    },
    title: {
      type: String,
      required: [true, 'Notification title is required'],
      trim: true,
    },
    body: {
      type: String,
      required: [true, 'Notification body is required'],
      trim: true,
    },
    type: {
      type: String,
      enum: ['appointment', 'prescription', 'lab_report', 'payment', 'promo', 'general'],
      default: 'general',
    },
    isRead: {
      type: Boolean,
      default: false,
    },
    relatedId: {
      type: mongoose.Schema.Types.ObjectId, // Link to custom ObjectId (e.g. Appointment, Prescription, etc.)
    },
    relatedModel: {
      type: String, // String naming the Model to pop up (e.g. 'Appointment', 'Prescription')
    },
  },
  {
    timestamps: true,
  }
);

// Index for quick fetching of user notifications
NotificationSchema.index({ user: 1, createdAt: -1 });

module.exports = mongoose.model('Notification', NotificationSchema);
