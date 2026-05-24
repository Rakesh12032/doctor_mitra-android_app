const Notification = require('../models/Notification');

/**
 * @desc    Get all notifications for the currently logged in patient or doctor
 * @route   GET /api/notifications
 * @access  Private
 */
exports.getMyNotifications = async (req, res) => {
  try {
    const notifications = await Notification.find({ recipient: req.user._id })
      .sort({ createdAt: -1 });

    res.status(200).json({
      success: true,
      count: notifications.length,
      notifications,
    });
  } catch (error) {
    console.error('❌ Get Notifications Error:', error);
    res.status(500).json({
      success: false,
      error: 'Server error occurred while retrieving alerts history',
    });
  }
};

/**
 * @desc    Mark a specific notification as read
 * @route   PUT /api/notifications/:id/read
 * @access  Private
 */
exports.markNotificationRead = async (req, res) => {
  try {
    const notification = await Notification.findById(req.params.id);

    if (!notification) {
      return res.status(404).json({
        success: false,
        error: 'Notification alert not found',
      });
    }

    // Verify ownership
    if (notification.recipient.toString() !== req.user._id.toString()) {
      return res.status(403).json({
        success: false,
        error: 'Not authorized to update this notification',
      });
    }

    notification.isRead = true;
    await notification.save();

    res.status(200).json({
      success: true,
      message: 'Notification marked as read',
      notification,
    });
  } catch (error) {
    console.error('❌ Mark Notification Read Error:', error);
    res.status(500).json({
      success: false,
      error: 'Server error occurred while updating alert status',
    });
  }
};

/**
 * @desc    Mark all user notifications as read
 * @route   PUT /api/notifications/read-all
 * @access  Private
 */
exports.markAllNotificationsRead = async (req, res) => {
  try {
    await Notification.updateMany(
      { recipient: req.user._id, isRead: false },
      { isRead: true }
    );

    res.status(200).json({
      success: true,
      message: 'All notifications successfully marked as read',
    });
  } catch (error) {
    console.error('❌ Mark All Notifications Read Error:', error);
    res.status(500).json({
      success: false,
      error: 'Server error occurred while updating alerts status',
    });
  }
};
