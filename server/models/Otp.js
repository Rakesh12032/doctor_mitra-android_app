const mongoose = require('mongoose');

const OtpSchema = new mongoose.Schema(
  {
    phone: {
      type: String,
      required: true,
      trim: true,
    },
    code: {
      type: String,
      required: true,
    },
    expiresAt: {
      type: Date,
      required: true,
      default: () => new Date(Date.now() + 5 * 60 * 1000), // Expires in 5 minutes
    },
  },
  {
    timestamps: true,
  }
);

// Create TTL index on expiresAt so MongoDB deletes expired OTPs automatically!
OtpSchema.index({ expiresAt: 1 }, { expireAfterSeconds: 0 });
OtpSchema.index({ phone: 1, code: 1 });

module.exports = mongoose.model('Otp', OtpSchema);
