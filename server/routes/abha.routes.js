const express = require('express');
const router = express.Router();
const {
  verifyAbha,
  linkAbha,
  getAbhaDetails,
} = require('../controllers/abha.controller');

// Import authentication check middlewares if needed, keeping it flexible
// e.g. router.use(protect); if we want to guard them

router.post('/verify', verifyAbha);
router.post('/link', linkAbha);
router.get('/:userId', getAbhaDetails);

module.exports = router;
