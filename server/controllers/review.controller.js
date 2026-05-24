const Review = require('../models/Review');
const Appointment = require('../models/Appointment');
const Doctor = require('../models/Doctor');

/**
 * @desc    Submit a patient review for a completed appointment
 * @route   POST /api/reviews
 * @access  Private (Patient)
 */
exports.submitReview = async (req, res) => {
  try {
    const {
      appointmentId,
      overallRating,
      waitTimeRating,
      behaviorRating,
      explanationRating,
      comment,
      isAnonymous = false,
    } = req.body;

    if (!appointmentId || !overallRating || !comment) {
      return res.status(400).json({
        success: false,
        error: 'Please provide appointmentId, overallRating, and comment feedback text',
      });
    }

    if (comment.trim().length < 30) {
      return res.status(400).json({
        success: false,
        error: 'Review comment must be at least 30 characters in length',
      });
    }

    const appointment = await Appointment.findById(appointmentId);
    if (!appointment) {
      return res.status(404).json({
        success: false,
        error: 'Appointment booking not found',
      });
    }

    // Verify booking owner
    if (appointment.patient.toString() !== req.user._id.toString()) {
      return res.status(403).json({
        success: false,
        error: 'Not authorized to submit feedback for this appointment',
      });
    }

    // Confirm consultation is complete
    if (appointment.status !== 'completed') {
      return res.status(400).json({
        success: false,
        error: 'You can only review consultations that are marked as completed',
      });
    }

    // Prevent double reviews
    const existingReview = await Review.findOne({ appointment: appointmentId });
    if (existingReview) {
      return res.status(400).json({
        success: false,
        error: 'You have already submitted a review for this consultation',
      });
    }

    const review = await Review.create({
      appointment: appointmentId,
      doctor: appointment.doctor,
      patient: req.user._id,
      overallRating,
      waitTimeRating,
      behaviorRating,
      explanationRating,
      comment: comment.trim(),
      isAnonymous,
    });

    res.status(201).json({
      success: true,
      message: 'Thank you! Your feedback has been posted successfully.',
      review,
    });
  } catch (error) {
    console.error('❌ Submit Review Error:', error);
    res.status(500).json({
      success: false,
      error: 'Server error occurred while saving feedback',
    });
  }
};

/**
 * @desc    Get all reviews for a specific doctor
 * @route   GET /api/reviews/doctor/:doctorId
 * @access  Public
 */
exports.getDoctorReviews = async (req, res) => {
  try {
    const { doctorId } = req.params;

    const reviews = await Review.find({ doctor: doctorId, isReported: false })
      .populate('patient', 'name profilePhoto')
      .sort({ createdAt: -1 });

    // Sanitize anonymous reviews to hide patient name/details
    const sanitizedReviews = reviews.map((rev) => {
      const reviewObj = rev.toObject();
      if (reviewObj.isAnonymous) {
        reviewObj.patient = {
          name: 'Anonymous Patient',
          profilePhoto: '',
        };
      }
      return reviewObj;
    });

    res.status(200).json({
      success: true,
      count: sanitizedReviews.length,
      reviews: sanitizedReviews,
    });
  } catch (error) {
    console.error('❌ Get Doctor Reviews Error:', error);
    res.status(500).json({
      success: false,
      error: 'Server error occurred while retrieving feedback list',
    });
  }
};

/**
 * @desc    Add doctor response to a patient review
 * @route   POST /api/reviews/:id/response
 * @access  Private (Doctor)
 */
exports.addDoctorResponse = async (req, res) => {
  try {
    const { response } = req.body;
    const reviewId = req.params.id;

    if (!response || response.trim() === '') {
      return res.status(400).json({
        success: false,
        error: 'Please enter response text',
      });
    }

    const review = await Review.findById(reviewId);
    if (!review) {
      return res.status(404).json({
        success: false,
        error: 'Review not found',
      });
    }

    // Confirm that this doctor is the one reviewed
    if (review.doctor.toString() !== req.user._id.toString()) {
      return res.status(403).json({
        success: false,
        error: 'Not authorized to reply to this review',
      });
    }

    review.doctorResponse = response.trim();
    await review.save();

    res.status(200).json({
      success: true,
      message: 'Response posted successfully',
      review,
    });
  } catch (error) {
    console.error('❌ Add Doctor Response Error:', error);
    res.status(500).json({
      success: false,
      error: 'Server error occurred while saving reply',
    });
  }
};
