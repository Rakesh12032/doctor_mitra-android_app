const express = require('express');
const router = express.Router();
const {
  sendOtp,
  verifyOtp,
  setupProfile,
  doctorLogin,
  adminLogin,
} = require('../controllers/auth.controller');
const { protect, protectTemp } = require('../middleware/auth.middleware');

// Public Auth Endpoints
router.post('/send-otp', sendOtp);
router.post('/verify-otp', verifyOtp);
router.post('/doctor-login', doctorLogin);
router.post('/admin-login', adminLogin);

// Protected Registration Profile Setup (Requires Temp Token)
router.post('/setup-profile', protectTemp, setupProfile);

// Get currently authenticated session details
router.get('/me', protect, (req, res) => {
  res.status(200).json({
    success: true,
    user: req.user || req.doctor,
  });
});

module.exports = router;
