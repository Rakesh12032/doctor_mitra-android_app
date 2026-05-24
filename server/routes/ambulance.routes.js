const express = require('express');
const router = express.Router();
const {
  getAllAmbulances,
  getNearbyAmbulances,
  createAmbulance,
  updateAmbulance,
} = require('../controllers/ambulance.controller');
const { protect } = require('../middleware/auth.middleware');
const { authorizeRoles } = require('../middleware/role.middleware');

// Public routes
router.get('/', getAllAmbulances);
router.get('/nearby', getNearbyAmbulances);

// Admin-only routes
router.post('/', protect, authorizeRoles('admin'), createAmbulance);
router.put('/:id', protect, authorizeRoles('admin'), updateAmbulance);

module.exports = router;
