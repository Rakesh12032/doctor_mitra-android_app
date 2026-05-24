const express = require('express');
const router = express.Router();
const { getVideoToken } = require('../controllers/consultation.controller');
const { protect } = require('../middleware/auth.middleware');

// Secure all consultation routes
router.use(protect);

router.get('/video-token/:appointmentId', getVideoToken);

module.exports = router;
