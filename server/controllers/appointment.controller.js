const Appointment = require('../models/Appointment');
const Doctor = require('../models/Doctor');
const Notification = require('../models/Notification');
const firebaseAdmin = require('../config/firebase');

/**
 * @desc    Book a new doctor appointment with proactive conflict check
 * @route   POST /api/appointments
 * @access  Private (Patient)
 */
exports.bookAppointment = async (req, res) => {
  try {
    const {
      doctor: doctorId,
      appointmentType,
      date,
      timeSlot,
      symptoms,
      notes,
      patientDetails,
      paymentMethod = 'cash_at_clinic',
    } = req.body;

    // Validate inputs
    if (!doctorId || !appointmentType || !date || !timeSlot) {
      return res.status(400).json({
        success: false,
        error: 'Please provide doctor, appointmentType, date, and timeSlot',
      });
    }

    // Confirm doctor exists and is approved
    const doctorObj = await Doctor.findOne({ _id: doctorId, isApproved: true, isActive: true });
    if (!doctorObj) {
      return res.status(404).json({
        success: false,
        error: 'The selected doctor is currently unavailable',
      });
    }

    // Standardize booking date (remove time part for consistency)
    const bookingDate = new Date(date);
    bookingDate.setHours(0, 0, 0, 0);

    // Proactive Double Booking Conflict Check
    const activeConflict = await Appointment.findOne({
      doctor: doctorId,
      date: bookingDate,
      timeSlot: timeSlot.trim(),
      status: { $in: ['pending', 'confirmed'] },
    });

    if (activeConflict) {
      return res.status(409).json({
        success: false,
        conflict: true,
        error: 'This time slot has already been booked. Please select another slot.',
      });
    }

    // Fetch the correct fee depending on the consultation type
    let feeAmount = 0;
    if (appointmentType === 'clinic') {
      feeAmount = doctorObj.consultationFees.clinic || 0;
    } else if (appointmentType === 'video') {
      feeAmount = doctorObj.consultationFees.video || 0;
    } else if (appointmentType === 'phone') {
      feeAmount = doctorObj.consultationFees.phone || 0;
    }

    // Set standard payment status
    const isOnlinePayment = ['UPI', 'card', 'netbanking'].includes(paymentMethod);
    const paymentStatus = isOnlinePayment ? 'pending' : 'pending'; // Cash is pending till paid at clinic
    const bookingStatus = isOnlinePayment ? 'pending' : 'confirmed'; // Cash is confirmed instantly, online pending pay checkout

    // Build patient metadata details
    const finalPatientDetails = {
      name: patientDetails?.name || req.user.name,
      age: patientDetails?.age || req.user.age || (req.user.dob ? new Date().getFullYear() - req.user.dob.getFullYear() : 30),
      gender: patientDetails?.gender || req.user.gender || 'Not specified',
      relation: patientDetails?.relation || 'self',
    };

    const newAppointment = await Appointment.create({
      patient: req.user._id,
      doctor: doctorId,
      appointmentType,
      date: bookingDate,
      timeSlot: timeSlot.trim(),
      status: bookingStatus,
      symptoms,
      notes,
      payment: {
        amount: feeAmount,
        method: paymentMethod,
        status: paymentStatus,
      },
      patientDetails: finalPatientDetails,
    });

    // Send push notification alerts
    try {
      // Alert Doctor
      await Notification.create({
        recipient: doctorId,
        recipientType: 'Doctor',
        title: 'New Appointment Booked 🏥',
        message: `Patient ${finalPatientDetails.name} has requested a ${appointmentType} consultation on ${date} at ${timeSlot}.`,
        relatedId: newAppointment._id,
        relatedModel: 'Appointment',
      });

      if (doctorObj.fcmToken) {
        await firebaseAdmin.messaging().send({
          token: doctorObj.fcmToken,
          notification: {
            title: 'New Appointment Booked 🏥',
            body: `Patient ${finalPatientDetails.name} booked a slot for ${timeSlot}.`,
          },
          data: {
            appointmentId: newAppointment._id.toString(),
            type: 'booking',
          },
        });
      }
    } catch (notifErr) {
      console.warn('⚠️ Push notification dispatch warning:', notifErr.message);
    }

    res.status(201).json({
      success: true,
      message: 'Appointment booked successfully',
      appointment: newAppointment,
    });
  } catch (error) {
    console.error('❌ Book Appointment Error:', error);
    res.status(500).json({
      success: false,
      error: 'Server error occurred during appointment booking',
    });
  }
};

/**
 * @desc    Get bookings list for currently logged in patient
 * @route   GET /api/appointments/my-bookings
 * @access  Private (Patient)
 */
exports.getMyBookings = async (req, res) => {
  try {
    const bookings = await Appointment.find({ patient: req.user._id })
      .populate('doctor', 'name speciality experience clinics profilePhoto rating consultationFees')
      .sort({ date: -1, timeSlot: -1 });

    res.status(200).json({
      success: true,
      count: bookings.length,
      bookings,
    });
  } catch (error) {
    console.error('❌ Get My Bookings Error:', error);
    res.status(500).json({
      success: false,
      error: 'Server error occurred while retrieving your bookings',
    });
  }
};

/**
 * @desc    Get bookings list for currently logged in doctor
 * @route   GET /api/appointments/doctor-bookings
 * @access  Private (Doctor)
 */
exports.getDoctorBookings = async (req, res) => {
  try {
    const bookings = await Appointment.find({ doctor: req.user._id })
      .populate('patient', 'name phone profilePhoto bloodGroup age gender')
      .sort({ date: 1, timeSlot: 1 });

    res.status(200).json({
      success: true,
      count: bookings.length,
      bookings,
    });
  } catch (error) {
    console.error('❌ Get Doctor Bookings Error:', error);
    res.status(500).json({
      success: false,
      error: 'Server error occurred while retrieving doctor schedule',
    });
  }
};

/**
 * @desc    Get details of a single appointment booking
 * @route   GET /api/appointments/:id
 * @access  Private
 */
exports.getAppointmentDetails = async (req, res) => {
  try {
    const appointment = await Appointment.findById(req.params.id)
      .populate('doctor', 'name speciality clinics registrationNumber profilePhoto rating availableDays')
      .populate('patient', 'name phone profilePhoto bloodGroup location')
      .populate('prescription');

    if (!appointment) {
      return res.status(404).json({
        success: false,
        error: 'Appointment not found',
      });
    }

    // Auth validation check: ensure user is either the doctor or the patient associated
    const isPatient = appointment.patient._id.toString() === req.user._id.toString();
    const isDoctor = appointment.doctor._id.toString() === req.user._id.toString();
    const isAdmin = req.user.role === 'admin';

    if (!isPatient && !isDoctor && !isAdmin) {
      return res.status(403).json({
        success: false,
        error: 'Not authorized to view details for this appointment',
      });
    }

    res.status(200).json({
      success: true,
      appointment,
    });
  } catch (error) {
    console.error('❌ Get Appointment Details Error:', error);
    res.status(500).json({
      success: false,
      error: 'Server error occurred while retrieving booking details',
    });
  }
};

/**
 * @desc    Cancel an appointment booking
 * @route   PUT /api/appointments/:id/cancel
 * @access  Private
 */
exports.cancelAppointment = async (req, res) => {
  try {
    const { cancelReason } = req.body;
    const appointment = await Appointment.findById(req.params.id);

    if (!appointment) {
      return res.status(404).json({
        success: false,
        error: 'Appointment not found',
      });
    }

    const isPatient = appointment.patient.toString() === req.user._id.toString();
    const isDoctor = appointment.doctor.toString() === req.user._id.toString();
    const isAdmin = req.user.role === 'admin';

    if (!isPatient && !isDoctor && !isAdmin) {
      return res.status(403).json({
        success: false,
        error: 'Not authorized to cancel this appointment',
      });
    }

    if (appointment.status === 'cancelled' || appointment.status === 'completed') {
      return res.status(400).json({
        success: false,
        error: `Cannot cancel an appointment that is already ${appointment.status}`,
      });
    }

    appointment.status = 'cancelled';
    appointment.cancelReason = cancelReason || 'Cancelled by user';
    await appointment.save();

    // Trigger alert updates
    try {
      const isUserCancelling = isPatient;
      const recipientId = isUserCancelling ? appointment.doctor : appointment.patient;
      const recipientType = isUserCancelling ? 'Doctor' : 'User';

      await Notification.create({
        recipient: recipientId,
        recipientType,
        title: 'Appointment Cancelled ⚠️',
        message: `Consultation on ${appointment.date.toDateString()} at ${appointment.timeSlot} has been cancelled. Reason: ${appointment.cancelReason}`,
        relatedId: appointment._id,
        relatedModel: 'Appointment',
      });
    } catch (notifErr) {
      console.warn('⚠️ Cancel notification failed:', notifErr.message);
    }

    res.status(200).json({
      success: true,
      message: 'Appointment successfully cancelled',
      appointment,
    });
  } catch (error) {
    console.error('❌ Cancel Appointment Error:', error);
    res.status(500).json({
      success: false,
      error: 'Server error occurred during cancellation',
    });
  }
};

/**
 * @desc    Mark appointment completed and generate Agora room or close consultation
 * @route   PUT /api/appointments/:id/complete
 * @access  Private (Doctor)
 */
exports.completeAppointment = async (req, res) => {
  try {
    const appointment = await Appointment.findById(req.params.id);

    if (!appointment) {
      return res.status(404).json({
        success: false,
        error: 'Appointment not found',
      });
    }

    // Confirm logged-in user is the assigned doctor
    if (appointment.doctor.toString() !== req.user._id.toString()) {
      return res.status(403).json({
        success: false,
        error: 'Only the assigned doctor can complete this appointment',
      });
    }

    if (appointment.status !== 'confirmed') {
      return res.status(400).json({
        success: false,
        error: `Cannot complete appointment in status: ${appointment.status}`,
      });
    }

    appointment.status = 'completed';
    if (appointment.payment.method === 'cash_at_clinic') {
      appointment.payment.status = 'successful'; // assume payment settled at clinic
    }
    await appointment.save();

    // Alert Patient
    try {
      await Notification.create({
        recipient: appointment.patient,
        recipientType: 'User',
        title: 'Consultation Completed 🎉',
        message: `Your appointment with Doctor is completed. Your digital prescription is active.`,
        relatedId: appointment._id,
        relatedModel: 'Appointment',
      });
    } catch (notifErr) {
      console.warn('⚠️ Complete notification failed:', notifErr.message);
    }

    res.status(200).json({
      success: true,
      message: 'Appointment marked as completed successfully',
      appointment,
    });
  } catch (error) {
    console.error('❌ Complete Appointment Error:', error);
    res.status(500).json({
      success: false,
      error: 'Server error occurred during completion',
    });
  }
};

/**
 * @desc    Reschedule appointment with slot conflict check
 * @route   PUT /api/appointments/:id/reschedule
 * @access  Private
 */
exports.rescheduleAppointment = async (req, res) => {
  try {
    const { newDate, newTimeSlot } = req.body;
    const appointmentId = req.params.id;

    if (!newDate || !newTimeSlot) {
      return res.status(400).json({
        success: false,
        error: 'Please provide a newDate and newTimeSlot',
      });
    }

    const appointment = await Appointment.findById(appointmentId);
    if (!appointment) {
      return res.status(404).json({
        success: false,
        error: 'Original appointment booking not found',
      });
    }

    const isPatient = appointment.patient.toString() === req.user._id.toString();
    const isDoctor = appointment.doctor.toString() === req.user._id.toString();

    if (!isPatient && !isDoctor) {
      return res.status(403).json({
        success: false,
        error: 'Not authorized to reschedule this appointment',
      });
    }

    // Standardize dates
    const reschedDate = new Date(newDate);
    reschedDate.setHours(0, 0, 0, 0);

    // Double-Booking slot conflict check
    const conflict = await Appointment.findOne({
      _id: { $ne: appointmentId },
      doctor: appointment.doctor,
      date: reschedDate,
      timeSlot: newTimeSlot.trim(),
      status: { $in: ['pending', 'confirmed'] },
    });

    if (conflict) {
      return res.status(409).json({
        success: false,
        conflict: true,
        error: 'The requested slot is already booked. Please choose another time slot.',
      });
    }

    // Save previous metadata details and cancel the old booking
    const prevDateString = appointment.date.toDateString();
    const prevSlotString = appointment.timeSlot;

    appointment.status = 'cancelled';
    appointment.cancelReason = `Rescheduled to ${newDate} at ${newTimeSlot}`;
    await appointment.save();

    // Create the new appointment linked back to the original
    const newAppointment = await Appointment.create({
      patient: appointment.patient,
      doctor: appointment.doctor,
      appointmentType: appointment.appointmentType,
      date: reschedDate,
      timeSlot: newTimeSlot.trim(),
      status: 'confirmed', // keep payment metadata intact
      symptoms: appointment.symptoms,
      notes: appointment.notes,
      payment: {
        amount: appointment.payment.amount,
        method: appointment.payment.method,
        status: appointment.payment.status,
        transactionId: appointment.payment.transactionId,
      },
      patientDetails: appointment.patientDetails,
      rescheduledFrom: appointmentId,
    });

    // Alert recipient of reschedule details
    try {
      const recipientId = isPatient ? appointment.doctor : appointment.patient;
      const recipientType = isPatient ? 'Doctor' : 'User';

      await Notification.create({
        recipient: recipientId,
        recipientType,
        title: 'Appointment Rescheduled 📅',
        message: `Consultation originally scheduled on ${prevDateString} at ${prevSlotString} is now rescheduled to ${newDate} at ${newTimeSlot}.`,
        relatedId: newAppointment._id,
        relatedModel: 'Appointment',
      });
    } catch (notifErr) {
      console.warn('⚠️ Reschedule notification warning:', notifErr.message);
    }

    res.status(200).json({
      success: true,
      message: 'Appointment rescheduled successfully',
      previousAppointment: appointment,
      newAppointment,
    });
  } catch (error) {
    console.error('❌ Reschedule Appointment Error:', error);
    res.status(500).json({
      success: false,
      error: 'Server error occurred while rescheduling',
    });
  }
};
