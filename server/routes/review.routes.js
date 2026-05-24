const express = require('express');
const router = express.Router();
const {
  submitReview,
  getDoctorReviews,
  addDoctorResponse,
} = require('../controllers/review.controller');
const { protect } = require('../middleware/auth.middleware');
const { checkRole } = require('../middleware/role.middleware');

// Public read endpoint
router.get('/doctor/:doctorId', getDoctorReviews);

// Private submit and response endpoints
router.post('/', protect, checkRole('patient'), submitReview);
router.post('/:id/response', protect, checkRole('doctor'), addDoctorResponse);

module.exports = router;
