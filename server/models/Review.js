const mongoose = require('mongoose');

const ReviewSchema = new mongoose.Schema(
  {
    appointment: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Appointment',
      required: [true, 'Appointment reference is required'],
      unique: true, // Only one review per appointment!
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
    overallRating: {
      type: Number,
      required: [true, 'Star rating is required'],
      min: 1,
      max: 5,
    },
    waitTimeRating: { type: Number, min: 1, max: 5 },
    behaviorRating: { type: Number, min: 1, max: 5 },
    explanationRating: { type: Number, min: 1, max: 5 },
    comment: {
      type: String,
      required: [true, 'Feedback text is required'],
      minlength: [30, 'Review comments must be at least 30 characters'],
    },
    isAnonymous: {
      type: Boolean,
      default: false,
    },
    doctorResponse: {
      type: String,
      default: '',
    },
    isReported: {
      type: Boolean,
      default: false,
    },
    reportReason: {
      type: String,
      default: '',
    },
  },
  {
    timestamps: true,
  }
);

// Statics method to calculate average rating of a doctor
ReviewSchema.statics.getAverageRating = async function (doctorId) {
  const obj = await this.aggregate([
    {
      $match: { doctor: doctorId, isReported: false }
    },
    {
      $group: {
        _id: '$doctor',
        averageRating: { $avg: '$overallRating' },
        ratingCount: { $sum: 1 }
      }
    }
  ]);

  try {
    if (obj.length > 0) {
      await mongoose.model('Doctor').findByIdAndUpdate(doctorId, {
        'rating.average': parseFloat(obj[0].averageRating.toFixed(1)),
        'rating.count': obj[0].ratingCount,
      });
    } else {
      await mongoose.model('Doctor').findByIdAndUpdate(doctorId, {
        'rating.average': 4.5,
        'rating.count': 0,
      });
    }
  } catch (err) {
    console.error(`Error updating rating stats: ${err}`);
  }
};

// Call getAverageRating after save
ReviewSchema.post('save', async function () {
  await this.constructor.getAverageRating(this.doctor);
});

// Call getAverageRating before delete
ReviewSchema.pre('remove', async function () {
  await this.constructor.getAverageRating(this.doctor);
});

module.exports = mongoose.model('Review', ReviewSchema);
