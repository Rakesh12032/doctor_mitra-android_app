const express = require('express');
const router = express.Router();
const {
  bookAppointment,
  getMyBookings,
  getDoctorBookings,
  getAppointmentDetails,
  cancelAppointment,
  completeAppointment,
  rescheduleAppointment,
} = require('../controllers/appointment.controller');
const { protect } = require('../middleware/auth.middleware');

// All appointment routes require authentication
router.use(protect);

// Base book and query endpoints
router.post('/', bookAppointment);
router.get('/my-bookings', getMyBookings);
router.get('/doctor-bookings', getDoctorBookings);

// Individual booking management endpoints
router.get('/:id', getAppointmentDetails);
router.put('/:id/cancel', cancelAppointment);
router.put('/:id/complete', completeAppointment);
router.put('/:id/reschedule', rescheduleAppointment);

module.exports = router;
