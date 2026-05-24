const express = require('express');
const router = express.Router();
const { getState, dispatchAction } = require('../controllers/stateSync.controller');
const { protect } = require('../middleware/auth.middleware');

// Both state-sync routes require authentication
router.use(protect);

// GET  /api/state   → Fetch all user data in one payload
router.get('/', getState);

// POST /api/actions → Dispatch a legacy action to the correct controller
router.post('/', dispatchAction);

module.exports = router;
