const express = require('express');
const router = express.Router();
const {
  createPrescription,
  getMyPrescriptions,
  getDoctorPrescriptions,
  getPrescriptionById,
} = require('../controllers/prescription.controller');
const { protect } = require('../middleware/auth.middleware');
const { checkRole } = require('../middleware/role.middleware');

// All prescription routes require JWT session protect
router.use(protect);

// Issue prescription (Doctor only)
router.post('/', checkRole('doctor'), createPrescription);

// Fetch logs
router.get('/my-prescriptions', checkRole('patient'), getMyPrescriptions);
router.get('/doctor-prescriptions', checkRole('doctor'), getDoctorPrescriptions);

// Single view
router.get('/:id', getPrescriptionById);

module.exports = router;
