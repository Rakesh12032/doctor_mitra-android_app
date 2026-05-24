const express = require('express');
const router = express.Router();
const {
  registerDoctor,
  loginDoctor,
  getAllDoctors,
  getDoctorById,
  getNearbyDoctors,
  getDoctorSlots,
  getDoctorEarnings,
  getDoctorEarningsSummary,
} = require('../controllers/doctor.controller');

// Doctor Auth (Public)
router.post('/register', registerDoctor);
router.post('/login', loginDoctor);

// Doctor Search and Geo-queries
router.get('/', getAllDoctors);
router.get('/nearby', getNearbyDoctors);

// Doctor Slot generation & detail profile
router.get('/:id', getDoctorById);
router.get('/:id/slots', getDoctorSlots);

// Doctor Earnings Screen APIs
router.get('/:id/earnings', getDoctorEarnings);
router.get('/:id/earnings/summary', getDoctorEarningsSummary);

module.exports = router;

