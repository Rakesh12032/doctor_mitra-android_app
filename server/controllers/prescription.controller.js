const Prescription = require('../models/Prescription');
const Appointment = require('../models/Appointment');
const Notification = require('../models/Notification');
const { uploadToCloud } = require('../config/cloudinary');

/**
 * @desc    Create a new digital medical prescription (Doctor Only)
 * @route   POST /api/prescriptions
 * @access  Private (Doctor)
 */
exports.createPrescription = async (req, res) => {
  try {
    const {
      appointmentId,
      symptoms,
      diagnosis,
      medicines,
      labTests = [],
      advice = '',
      followUpDate,
    } = req.body;

    if (!appointmentId || !diagnosis || !medicines || medicines.length === 0) {
      return res.status(400).json({
        success: false,
        error: 'Please provide appointmentId, diagnosis, and medicines list',
      });
    }

    const appointment = await Appointment.findById(appointmentId).populate('patient doctor');
    if (!appointment) {
      return res.status(404).json({
        success: false,
        error: 'Appointment booking not found',
      });
    }

    // Confirm that the requesting doctor is assigned to this appointment
    if (appointment.doctor._id.toString() !== req.user._id.toString()) {
      return res.status(403).json({
        success: false,
        error: 'Not authorized. You are not the assigned doctor for this consultation.',
      });
    }

    // Create a detailed text-based digital prescription summary
    const formattedMedicines = medicines
      .map(
        (med, idx) =>
          `${idx + 1}. Name: ${med.name} | Dosage: ${med.dosage} | Frequency: ${
            med.frequency
          } | Duration: ${med.duration} | Instructions: ${med.instructions || 'N/A'}`
      )
      .join('\n');

    const prescriptionText = `
=============================================
             DOCTOR MITRA PRESCRIPTION       
=============================================
DATE: ${new Date().toLocaleDateString()}
PATIENT: ${appointment.patientDetails?.name || appointment.patient.name} (${
      appointment.patientDetails?.age || ''
    } yrs, ${appointment.patientDetails?.gender || ''})
DOCTOR: Dr. ${appointment.doctor.name} (${appointment.doctor.speciality})
MCI REG NO: ${appointment.doctor.registrationNumber || 'N/A'}
---------------------------------------------
SYMPTOMS:
${symptoms || appointment.symptoms || 'N/A'}

DIAGNOSIS:
${diagnosis}

MEDICINES PRESCRIBED:
${formattedMedicines}

LAB TESTS ORDERED:
${labTests.length > 0 ? labTests.join(', ') : 'None'}

GENERAL ADVICE:
${advice || 'None'}

FOLLOW UP DATE:
${followUpDate ? new Date(followUpDate).toLocaleDateString() : 'As needed'}
=============================================
Thank you for trusting Doctor Mitra! 🏥
    `.trim();

    // Convert text summary to file buffer for uploading
    const fileBuffer = Buffer.from(prescriptionText, 'utf-8');
    const uploadResult = await uploadToCloud(
      fileBuffer,
      `prescription-${appointmentId}.txt`,
      'text/plain',
      'doctormitra/prescriptions'
    );

    // Save prescription database entry
    const prescription = await Prescription.create({
      appointment: appointmentId,
      doctor: req.user._id,
      patient: appointment.patient._id,
      symptoms: symptoms || appointment.symptoms || '',
      diagnosis,
      medicines,
      labTests,
      advice,
      followUpDate: followUpDate ? new Date(followUpDate) : null,
      pdfUrl: uploadResult.url,
    });

    // Update appointment status to completed and link prescription
    appointment.status = 'completed';
    appointment.prescription = prescription._id;
    await appointment.save();

    // Trigger notification
    try {
      await Notification.create({
        recipient: appointment.patient._id,
        recipientType: 'User',
        title: 'New Digital Prescription 📄',
        message: `Dr. ${req.user.name} has added a new digital prescription for your consultation.`,
        relatedId: prescription._id,
        relatedModel: 'Prescription',
      });
    } catch (notifErr) {
      console.warn('⚠️ Prescription notification warning:', notifErr.message);
    }

    res.status(201).json({
      success: true,
      message: 'Prescription generated successfully',
      prescription,
    });
  } catch (error) {
    console.error('❌ Create Prescription Error:', error);
    res.status(500).json({
      success: false,
      error: 'Server error occurred during prescription generation',
    });
  }
};

/**
 * @desc    Get all prescriptions for the currently authenticated patient
 * @route   GET /api/prescriptions/my-prescriptions
 * @access  Private (Patient)
 */
exports.getMyPrescriptions = async (req, res) => {
  try {
    const prescriptions = await Prescription.find({ patient: req.user._id })
      .populate('doctor', 'name speciality profilePhoto clinics registrationNumber')
      .populate('appointment', 'date timeSlot appointmentType')
      .sort({ createdAt: -1 });

    res.status(200).json({
      success: true,
      count: prescriptions.length,
      prescriptions,
    });
  } catch (error) {
    console.error('❌ Get My Prescriptions Error:', error);
    res.status(500).json({
      success: false,
      error: 'Server error occurred while retrieving prescriptions',
    });
  }
};

/**
 * @desc    Get all prescriptions issued by the currently authenticated doctor
 * @route   GET /api/prescriptions/doctor-prescriptions
 * @access  Private (Doctor)
 */
exports.getDoctorPrescriptions = async (req, res) => {
  try {
    const prescriptions = await Prescription.find({ doctor: req.user._id })
      .populate('patient', 'name phone profilePhoto dob bloodGroup')
      .populate('appointment', 'date timeSlot appointmentType')
      .sort({ createdAt: -1 });

    res.status(200).json({
      success: true,
      count: prescriptions.length,
      prescriptions,
    });
  } catch (error) {
    console.error('❌ Get Doctor Prescriptions Error:', error);
    res.status(500).json({
      success: false,
      error: 'Server error occurred while retrieving prescription logs',
    });
  }
};

/**
 * @desc    Get details of a single digital prescription
 * @route   GET /api/prescriptions/:id
 * @access  Private
 */
exports.getPrescriptionById = async (req, res) => {
  try {
    const prescription = await Prescription.findById(req.params.id)
      .populate('doctor', 'name speciality clinics profilePhoto registrationNumber')
      .populate('patient', 'name phone profilePhoto dob location bloodGroup')
      .populate('appointment', 'date timeSlot appointmentType status');

    if (!prescription) {
      return res.status(404).json({
        success: false,
        error: 'Prescription record not found',
      });
    }

    // Verify authorized party
    const isPatient = prescription.patient._id.toString() === req.user._id.toString();
    const isDoctor = prescription.doctor._id.toString() === req.user._id.toString();
    const isAdmin = req.user.role === 'admin';

    if (!isPatient && !isDoctor && !isAdmin) {
      return res.status(403).json({
        success: false,
        error: 'Not authorized to view this prescription',
      });
    }

    res.status(200).json({
      success: true,
      prescription,
    });
  } catch (error) {
    console.error('❌ Get Prescription By ID Error:', error);
    res.status(500).json({
      success: false,
      error: 'Server error occurred while retrieving prescription details',
    });
  }
};
