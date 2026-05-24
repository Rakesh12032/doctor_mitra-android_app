const User = require('../models/User');
const Doctor = require('../models/Doctor');
const Appointment = require('../models/Appointment');
const HealthRecord = require('../models/HealthRecord');
const Notification = require('../models/Notification');
const Prescription = require('../models/Prescription');
const Review = require('../models/Review');

/**
 * @desc    Fetch all relevant data for current user in a single JSON payload.
 *          This bridges the legacy Flutter runRemoteAction pattern with the new REST API.
 * @route   GET /api/state
 * @access  Private
 */
exports.getState = async (req, res) => {
  try {
    const userId = req.user._id || req.user.id;
    const userRole = req.user.role;

    let responseData = {};

    if (userRole === 'admin') {
      // Admin gets aggregated data
      const [doctors, appointments, users, notifications] = await Promise.all([
        Doctor.find({}).lean(),
        Appointment.find({}).populate('patient doctor', 'name phone email').sort({ createdAt: -1 }).limit(100).lean(),
        User.find({}).select('-__v').lean(),
        Notification.find({}).sort({ createdAt: -1 }).limit(50).lean(),
      ]);

      responseData = {
        role: 'admin',
        doctors,
        appointments,
        users,
        notifications,
        stats: {
          totalDoctors: doctors.length,
          totalUsers: users.length,
          totalAppointments: appointments.length,
          pendingApprovals: doctors.filter(d => !d.isApproved).length,
        },
      };
    } else if (userRole === 'doctor') {
      // Doctor gets their own data
      const [appointments, reviews, notifications] = await Promise.all([
        Appointment.find({ doctor: userId }).populate('patient', 'name phone email').sort({ createdAt: -1 }).lean(),
        Review.find({ doctor: userId }).populate('user', 'name').sort({ createdAt: -1 }).lean(),
        Notification.find({ recipient: userId }).sort({ createdAt: -1 }).limit(30).lean(),
      ]);

      responseData = {
        role: 'doctor',
        profile: req.user.toObject ? req.user.toObject() : req.user,
        appointments,
        reviews,
        notifications,
      };
    } else {
      // Patient gets their own data
      const [appointments, healthRecords, prescriptions, notifications] = await Promise.all([
        Appointment.find({ patient: userId }).populate('doctor', 'name speciality profilePhoto clinics consultationFees rating').sort({ createdAt: -1 }).lean(),
        HealthRecord.find({ user: userId }).sort({ createdAt: -1 }).lean(),
        Prescription.find({ patient: userId }).populate('doctor', 'name speciality').sort({ createdAt: -1 }).lean(),
        Notification.find({ recipient: userId }).sort({ createdAt: -1 }).limit(30).lean(),
      ]);

      // Also fetch approved doctors for browse
      const doctors = await Doctor.find({ isApproved: true, isActive: true }).lean();

      responseData = {
        role: 'patient',
        profile: req.user.toObject ? req.user.toObject() : req.user,
        doctors,
        appointments,
        healthRecords,
        prescriptions,
        notifications,
      };
    }

    res.status(200).json({
      success: true,
      timestamp: new Date().toISOString(),
      data: responseData,
    });
  } catch (error) {
    console.error('❌ State Sync GET Error:', error);
    res.status(500).json({
      success: false,
      error: 'Server error occurred while syncing state data',
    });
  }
};

/**
 * @desc    Parse an action from the legacy Flutter client and route it to the
 *          correct existing controller logic. This avoids rewriting all Flutter
 *          API calls at once — the client can gradually migrate.
 * @route   POST /api/actions
 * @access  Private
 */
exports.dispatchAction = async (req, res) => {
  try {
    const { type, payload } = req.body;

    if (!type) {
      return res.status(400).json({
        success: false,
        error: 'Action type is required. Example: { type: "BOOK_APPOINTMENT", payload: {...} }',
      });
    }

    // Map legacy action types to internal handlers
    switch (type) {
      case 'BOOK_APPOINTMENT': {
        // Forward to appointment controller logic
        const appointmentCtrl = require('./appointment.controller');
        req.body = payload || {};
        return appointmentCtrl.bookAppointment(req, res);
      }

      case 'CANCEL_APPOINTMENT': {
        const appointmentCtrl = require('./appointment.controller');
        req.params = { id: payload?.appointmentId };
        return appointmentCtrl.cancelAppointment(req, res);
      }

      case 'ADD_HEALTH_RECORD': {
        const healthCtrl = require('./healthRecord.controller');
        req.body = payload || {};
        return healthCtrl.createRecord(req, res);
      }

      case 'ADD_REVIEW': {
        const reviewCtrl = require('./review.controller');
        req.body = payload || {};
        return reviewCtrl.createReview(req, res);
      }

      case 'UPDATE_PROFILE': {
        const userId = req.user._id || req.user.id;
        const updateData = payload || {};
        // Remove sensitive fields
        delete updateData.role;
        delete updateData.isActive;

        if (req.user.role === 'doctor') {
          const doctor = await Doctor.findByIdAndUpdate(userId, updateData, { new: true, runValidators: true });
          return res.status(200).json({ success: true, profile: doctor });
        } else {
          const user = await User.findByIdAndUpdate(userId, updateData, { new: true, runValidators: true });
          return res.status(200).json({ success: true, profile: user });
        }
      }

      case 'UPDATE_FCM_TOKEN': {
        const userId = req.user._id || req.user.id;
        const { fcmToken } = payload || {};
        if (!fcmToken) {
          return res.status(400).json({ success: false, error: 'fcmToken is required' });
        }

        if (req.user.role === 'doctor') {
          await Doctor.findByIdAndUpdate(userId, { fcmToken });
        } else {
          await User.findByIdAndUpdate(userId, { fcmToken });
        }
        return res.status(200).json({ success: true, message: 'FCM token updated' });
      }

      case 'MARK_NOTIFICATION_READ': {
        const notifCtrl = require('./notification.controller');
        req.params = { id: payload?.notificationId };
        return notifCtrl.markAsRead(req, res);
      }

      default:
        return res.status(400).json({
          success: false,
          error: `Unknown action type: "${type}". Supported: BOOK_APPOINTMENT, CANCEL_APPOINTMENT, ADD_HEALTH_RECORD, ADD_REVIEW, UPDATE_PROFILE, UPDATE_FCM_TOKEN, MARK_NOTIFICATION_READ`,
        });
    }
  } catch (error) {
    console.error('❌ Action Dispatch Error:', error);
    res.status(500).json({
      success: false,
      error: 'Server error occurred while dispatching action',
    });
  }
};
