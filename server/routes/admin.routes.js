const express = require('express');
const router = express.Router();
const {
  getDashboardStats,
  approveDoctor,
  toggleDoctorActive,
  getAllRegisteredDoctors,
} = require('../controllers/admin.controller');
const { protect } = require('../middleware/auth.middleware');
const { checkRole } = require('../middleware/role.middleware');

// Secure all admin routes
router.use(protect);
router.use(checkRole('admin'));

// Admin Dashboard stats
router.get('/dashboard-stats', getDashboardStats);

// Registered doctors management
router.get('/doctors', getAllRegisteredDoctors);
router.put('/doctors/:id/approve', approveDoctor);
router.put('/doctors/:id/toggle-active', toggleDoctorActive);

module.exports = router;
