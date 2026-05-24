const HealthRecord = require('../models/HealthRecord');
const { uploadToCloud } = require('../config/cloudinary');

/**
 * @desc    Upload a new patient health record file (pdf, jpeg, png)
 * @route   POST /api/health-records
 * @access  Private (Patient)
 */
exports.uploadHealthRecord = async (req, res) => {
  try {
    const { title, category, notes, date } = req.body;

    if (!req.file) {
      return res.status(400).json({
        success: false,
        error: 'Please upload a medical document file (JPG, PNG, or PDF)',
      });
    }

    if (!title || !category) {
      return res.status(400).json({
        success: false,
        error: 'Please provide document title and category',
      });
    }

    // Upload memory buffer to Cloudinary or fallback to local uploads folder
    const uploadResult = await uploadToCloud(
      req.file.buffer,
      req.file.originalname,
      req.file.mimetype,
      'doctormitra/health_records'
    );

    // Save metadata log
    const healthRecord = await HealthRecord.create({
      patient: req.user._id,
      title: title.trim(),
      category,
      date: date ? new Date(date) : new Date(),
      fileUrl: uploadResult.url,
      fileType: req.file.mimetype.split('/')[1] || 'pdf',
      notes: notes || '',
    });

    res.status(201).json({
      success: true,
      message: 'Health record uploaded successfully',
      healthRecord,
    });
  } catch (error) {
    console.error('❌ Upload Health Record Error:', error);
    res.status(500).json({
      success: false,
      error: 'Server error occurred during file upload',
    });
  }
};

/**
 * @desc    Get all health records for the currently authenticated patient
 * @route   GET /api/health-records
 * @access  Private (Patient)
 */
exports.getMyHealthRecords = async (req, res) => {
  try {
    const records = await HealthRecord.find({ patient: req.user._id })
      .populate('sharedWith', 'name speciality profilePhoto')
      .sort({ date: -1 });

    res.status(200).json({
      success: true,
      count: records.length,
      records,
    });
  } catch (error) {
    console.error('❌ Get My Health Records Error:', error);
    res.status(500).json({
      success: false,
      error: 'Server error occurred while retrieving health vault',
    });
  }
};

/**
 * @desc    Get single health record details
 * @route   GET /api/health-records/:id
 * @access  Private
 */
exports.getHealthRecordById = async (req, res) => {
  try {
    const record = await HealthRecord.findById(req.params.id)
      .populate('patient', 'name phone profilePhoto')
      .populate('sharedWith', 'name speciality profilePhoto');

    if (!record) {
      return res.status(404).json({
        success: false,
        error: 'Health record not found',
      });
    }

    // Verify authorized user (must be the owner patient, or a doctor shared with)
    const isOwner = record.patient._id.toString() === req.user._id.toString();
    const isDoctorShared = req.user.role === 'doctor' && record.sharedWith.some(
      (doc) => doc._id.toString() === req.user._id.toString()
    );
    const isAdmin = req.user.role === 'admin';

    if (!isOwner && !isDoctorShared && !isAdmin) {
      return res.status(403).json({
        success: false,
        error: 'Not authorized to view this health record',
      });
    }

    res.status(200).json({
      success: true,
      record,
    });
  } catch (error) {
    console.error('❌ Get Health Record Error:', error);
    res.status(500).json({
      success: false,
      error: 'Server error occurred while retrieving record details',
    });
  }
};

/**
 * @desc    Share a health record with a doctor
 * @route   POST /api/health-records/:id/share
 * @access  Private (Patient)
 */
exports.shareRecordWithDoctor = async (req, res) => {
  try {
    const { doctorId } = req.body;

    if (!doctorId) {
      return res.status(400).json({
        success: false,
        error: 'Please provide doctorId to share this record with',
      });
    }

    const record = await HealthRecord.findById(req.params.id);
    if (!record) {
      return res.status(404).json({
        success: false,
        error: 'Health record not found',
      });
    }

    // Confirm owner
    if (record.patient.toString() !== req.user._id.toString()) {
      return res.status(403).json({
        success: false,
        error: 'Not authorized to share this record',
      });
    }

    // Add doctor to shared array if not already present
    if (!record.sharedWith.includes(doctorId)) {
      record.sharedWith.push(doctorId);
      await record.save();
    }

    res.status(200).json({
      success: true,
      message: 'Health record shared successfully with doctor',
      record,
    });
  } catch (error) {
    console.error('❌ Share Health Record Error:', error);
    res.status(500).json({
      success: false,
      error: 'Server error occurred while sharing record',
    });
  }
};

/**
 * @desc    Delete health record
 * @route   DELETE /api/health-records/:id
 * @access  Private (Patient)
 */
exports.deleteHealthRecord = async (req, res) => {
  try {
    const record = await HealthRecord.findById(req.params.id);

    if (!record) {
      return res.status(404).json({
        success: false,
        error: 'Health record not found',
      });
    }

    // Confirm owner
    if (record.patient.toString() !== req.user._id.toString()) {
      return res.status(403).json({
        success: false,
        error: 'Not authorized to delete this health record',
      });
    }

    await record.deleteOne();

    res.status(200).json({
      success: true,
      message: 'Health record successfully deleted',
    });
  } catch (error) {
    console.error('❌ Delete Health Record Error:', error);
    res.status(500).json({
      success: false,
      error: 'Server error occurred while deleting record',
    });
  }
};
