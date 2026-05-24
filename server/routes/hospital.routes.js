const express = require('express');
const router = express.Router();
const {
  getAllHospitals,
  getHospitalById,
  getNearbyHospitals,
  createHospital,
  updateHospital,
} = require('../controllers/hospital.controller');
const { protect } = require('../middleware/auth.middleware');
const { authorizeRoles } = require('../middleware/role.middleware');

// Public routes
router.get('/', getAllHospitals);
router.get('/nearby', getNearbyHospitals);
router.get('/:id', getHospitalById);

// Admin-only routes
router.post('/', protect, authorizeRoles('admin'), createHospital);
router.put('/:id', protect, authorizeRoles('admin'), updateHospital);

module.exports = router;
