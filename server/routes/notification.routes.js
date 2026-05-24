const express = require('express');
const router = express.Router();
const {
  getMyNotifications,
  markNotificationRead,
  markAllNotificationsRead,
} = require('../controllers/notification.controller');
const { protect } = require('../middleware/auth.middleware');

// All notification routes require JWT session protect
router.use(protect);

router.get('/', getMyNotifications);
router.put('/read-all', markAllNotificationsRead);
router.put('/:id/read', markNotificationRead);

module.exports = router;
