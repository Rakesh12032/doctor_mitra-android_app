const Doctor = require('../models/Doctor');
const User = require('../models/User');
const Appointment = require('../models/Appointment');
const Notification = require('../models/Notification');

/**
 * @desc    Get Admin dashboard statistics
 * @route   GET /api/admin/dashboard-stats
 * @access  Private (Admin Only)
 */
exports.getDashboardStats = async (req, res) => {
  try {
    const totalPatients = await User.countDocuments();
    const totalDoctors = await Doctor.countDocuments({ isApproved: true });
    const pendingDoctors = await Doctor.countDocuments({ isApproved: false });

    // Aggregate booking counts by status
    const bookingStats = await Appointment.aggregate([
      {
        $group: {
          _id: '$status',
          count: { $sum: 1 },
        },
      },
    ]);

    const bookingsByStatus = {
      pending: 0,
      confirmed: 0,
      completed: 0,
      cancelled: 0,
    };

    bookingStats.forEach((stat) => {
      if (bookingsByStatus.hasOwnProperty(stat._id)) {
        bookingsByStatus[stat._id] = stat.count;
      }
    });

    const totalBookings = Object.values(bookingsByStatus).reduce((a, b) => a + b, 0);

    // Aggregate total captured consultation fee revenue
    const revenueStats = await Appointment.aggregate([
      {
        $match: {
          status: 'completed',
          'payment.status': 'successful',
        },
      },
      {
        $group: {
          _id: null,
          totalRevenue: { $sum: '$payment.amount' },
        },
      },
    ]);

    const totalRevenue = revenueStats.length > 0 ? revenueStats[0].totalRevenue : 0;

    // Daily booking trends for the last 7 days
    const lastWeek = new Date();
    lastWeek.setDate(lastWeek.getDate() - 7);

    const trendsStats = await Appointment.aggregate([
      {
        $match: {
          createdAt: { $gte: lastWeek },
        },
      },
      {
        $group: {
          _id: {
            $dateToString: { format: '%Y-%m-%d', date: '$createdAt' },
          },
          count: { $sum: 1 },
        },
      },
      {
        $sort: { _id: 1 },
      },
    ]);

    res.status(200).json({
      success: true,
      stats: {
        totalPatients,
        totalDoctors,
        pendingDoctors,
        totalBookings,
        bookingsByStatus,
        totalRevenue,
        trends: trendsStats,
      },
    });
  } catch (error) {
    console.error('❌ Get Dashboard Stats Error:', error);
    res.status(500).json({
      success: false,
      error: 'Server error occurred while calculating analytics',
    });
  }
};

/**
 * @desc    Approve a doctor registration profile
 * @route   PUT /api/admin/doctors/:id/approve
 * @access  Private (Admin Only)
 */
exports.approveDoctor = async (req, res) => {
  try {
    const doctorId = req.params.id;

    const doctor = await Doctor.findById(doctorId);
    if (!doctor) {
      return res.status(404).json({
        success: false,
        error: 'Doctor registration profile not found',
      });
    }

    if (doctor.isApproved) {
      return res.status(400).json({
        success: false,
        error: 'Doctor profile is already approved',
      });
    }

    doctor.isApproved = true;
    doctor.isVerified = true; // Auto-verify on admin approval
    await doctor.save();

    // Alert Doctor
    try {
      await Notification.create({
        recipient: doctorId,
        recipientType: 'Doctor',
        title: 'Registration Approved! 🌟',
        message: 'Your Doctor Mitra registration has been approved. You are now visible to patients.',
      });
    } catch (notifErr) {
      console.warn('⚠️ Approve notification failed:', notifErr.message);
    }

    res.status(200).json({
      success: true,
      message: `Doctor ${doctor.name} profile successfully approved.`,
      doctor,
    });
  } catch (error) {
    console.error('❌ Approve Doctor Error:', error);
    res.status(500).json({
      success: false,
      error: 'Server error occurred while approving profile',
    });
  }
};

/**
 * @desc    Toggle doctor active status (suspend/activate)
 * @route   PUT /api/admin/doctors/:id/toggle-active
 * @access  Private (Admin Only)
 */
exports.toggleDoctorActive = async (req, res) => {
  try {
    const doctor = await Doctor.findById(req.params.id);
    if (!doctor) {
      return res.status(404).json({
        success: false,
        error: 'Doctor profile not found',
      });
    }

    doctor.isActive = !doctor.isActive;
    await doctor.save();

    res.status(200).json({
      success: true,
      message: `Doctor profile has been ${doctor.isActive ? 'activated' : 'suspended'} successfully`,
      doctor,
    });
  } catch (error) {
    console.error('❌ Toggle Doctor Active Error:', error);
    res.status(500).json({
      success: false,
      error: 'Server error occurred while updating profile status',
    });
  }
};

/**
 * @desc    Get list of all registered doctors (both approved and pending)
 * @route   GET /api/admin/doctors
 * @access  Private (Admin Only)
 */
exports.getAllRegisteredDoctors = async (req, res) => {
  try {
    const doctors = await Doctor.find().sort({ createdAt: -1 });

    res.status(200).json({
      success: true,
      count: doctors.length,
      doctors,
    });
  } catch (error) {
    console.error('❌ Admin Get All Doctors Error:', error);
    res.status(500).json({
      success: false,
      error: 'Server error occurred while retrieving doctors list',
    });
  }
};
