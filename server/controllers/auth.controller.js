const jwt = require('jsonwebtoken');
const User = require('../models/User');
const Doctor = require('../models/Doctor');
const Otp = require('../models/Otp');
const { sendOtpSms } = require('../utils/sms');

// Helper to sign JWT tokens
const signToken = (payload) => {
  return jwt.sign(payload, process.env.JWT_SECRET, {
    expiresIn: process.env.JWT_EXPIRES_IN || '7d',
  });
};

/**
 * @desc    Generate & Send SMS OTP to Patient
 * @route   POST /api/auth/send-otp
 * @access  Public
 */
exports.sendOtp = async (req, res) => {
  try {
    const { phone } = req.body;

    if (!phone || phone.trim().length !== 10) {
      return res.status(400).json({
        success: false,
        error: 'Please enter a valid 10-digit mobile number',
      });
    }

    const cleanPhone = phone.trim();

    // Generate random 6-digit OTP
    let otpCode = Math.floor(100000 + Math.random() * 900000).toString();

    // Hardcode OTP for demo patient to enable app store review / easy testing
    if (cleanPhone === '9876543210') {
      otpCode = '123456';
    }

    // Save OTP to database (upsert: update if exists, insert if new)
    const expiresAt = new Date(Date.now() + 5 * 60 * 1000); // 5 min TTL
    await Otp.findOneAndUpdate(
      { phone: cleanPhone },
      { code: otpCode, expiresAt },
      { upsert: true, new: true }
    );

    // Trigger SMS delivery via 2Factor Gateway
    const smsResult = await sendOtpSms(cleanPhone, otpCode);

    if (!smsResult.success) {
      return res.status(500).json({
        success: false,
        error: smsResult.message || 'Failed to dispatch SMS verification code',
      });
    }

    res.status(200).json({
      success: true,
      message: `OTP sent successfully to +91 ${cleanPhone}`,
    });
  } catch (error) {
    console.error(`❌ Send OTP Error:`, error);
    res.status(500).json({
      success: false,
      error: 'Server error occurred while sending OTP',
    });
  }
};

/**
 * @desc    Verify SMS OTP & Login/Register Patient
 * @route   POST /api/auth/verify-otp
 * @access  Public
 */
exports.verifyOtp = async (req, res) => {
  try {
    const { phone, code } = req.body;

    if (!phone || !code) {
      return res.status(400).json({
        success: false,
        error: 'Please provide both mobile number and OTP code',
      });
    }

    const cleanPhone = phone.trim();
    const cleanCode = code.trim();

    // Hardcode bypass check for demo user
    const isDemoUser = cleanPhone === '9876543210' && cleanCode === '123456';

    if (!isDemoUser) {
      // Find OTP record
      const otpRecord = await Otp.findOne({ phone: cleanPhone, code: cleanCode });

      if (!otpRecord) {
        return res.status(400).json({
          success: false,
          error: 'Invalid or expired OTP code',
        });
      }

      // Delete verified OTP record
      await Otp.deleteOne({ _id: otpRecord._id });
    }

    // Check if patient profile exists
    let user = await User.findOne({ phone: cleanPhone });

    if (!user) {
      // User does not exist yet. Sign a temporary token containing their phone
      // so they can securely call /api/auth/setup-profile in next step!
      const tempToken = signToken({ phone: cleanPhone, isNewUser: true });

      return res.status(200).json({
        success: true,
        isNewUser: true,
        token: tempToken,
        message: 'OTP verified. Please complete your profile registration.',
      });
    }

    // Check if active
    if (!user.isActive) {
      return res.status(403).json({
        success: false,
        error: 'Your account is deactivated. Please contact support.',
      });
    }

    // User exists. Sign normal auth token
    const token = signToken({ id: user._id, role: 'patient' });

    res.status(200).json({
      success: true,
      isNewUser: false,
      token,
      user,
    });
  } catch (error) {
    console.error(`❌ Verify OTP Error:`, error);
    res.status(500).json({
      success: false,
      error: 'Server error occurred during verification',
    });
  }
};

/**
 * @desc    Complete Registration / Profile Setup for New Patient
 * @route   POST /api/auth/setup-profile
 * @access  Private (requires temporary token from verify-otp)
 */
exports.setupProfile = async (req, res) => {
  try {
    // Temp auth check will populate req.tempPhone via setup middleware
    const phone = req.tempPhone;
    if (!phone) {
      return res.status(401).json({
        success: false,
        error: 'Unauthorized profile setup session. Please verify OTP again.',
      });
    }

    const { name, age, dob, gender, bloodGroup, city, address, lat, lng } = req.body;

    if (!name || name.trim() === '') {
      return res.status(400).json({
        success: false,
        error: 'Please enter your full name',
      });
    }

    // Check if user already exists
    let existingUser = await User.findOne({ phone });
    if (existingUser) {
      return res.status(400).json({
        success: false,
        error: 'Profile already registered for this number',
      });
    }

    // Calculate Date of Birth if only age is provided
    let calculatedDob = dob ? new Date(dob) : null;
    if (!calculatedDob && age) {
      calculatedDob = new Date();
      calculatedDob.setFullYear(calculatedDob.getFullYear() - parseInt(age));
    }

    // Create user profile
    const user = await User.create({
      phone,
      name: name.trim(),
      dob: calculatedDob,
      gender,
      bloodGroup,
      location: {
        city: city || '',
        address: address || '',
        lat: lat ? parseFloat(lat) : null,
        lng: lng ? parseFloat(lng) : null,
      },
    });

    // Sign permanent token
    const token = signToken({ id: user._id, role: 'patient' });

    res.status(201).json({
      success: true,
      token,
      user,
    });
  } catch (error) {
    console.error(`❌ Setup Profile Error:`, error);
    res.status(500).json({
      success: false,
      error: 'Server error occurred during profile registration',
    });
  }
};

/**
 * @desc    Doctor Login Authentication
 * @route   POST /api/auth/doctor-login
 * @access  Public
 */
exports.doctorLogin = async (req, res) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({
        success: false,
        error: 'Please enter both Email ID and Password',
      });
    }

    // Find doctor and select password explicitly
    const doctor = await Doctor.findOne({ email: email.trim().toLowerCase() }).select('+password');

    if (!doctor) {
      return res.status(400).json({
        success: false,
        error: 'Invalid email or password',
      });
    }

    // Check if active
    if (!doctor.isActive) {
      return res.status(403).json({
        success: false,
        error: 'Your profile has been suspended. Please contact admin.',
      });
    }

    // Verify hashed password
    const isMatch = await doctor.matchPassword(password);
    if (!isMatch) {
      return res.status(400).json({
        success: false,
        error: 'Invalid email or password',
      });
    }

    // Check if approved by admin
    if (!doctor.isApproved) {
      return res.status(403).json({
        success: false,
        isApproved: false,
        error: 'Your registration is pending admin approval. You will receive an alert once verified.',
      });
    }

    // Sign auth token
    const token = signToken({ id: doctor._id, role: 'doctor' });

    res.status(200).json({
      success: true,
      token,
      doctor: {
        _id: doctor._id,
        name: doctor.name,
        email: doctor.email,
        phone: doctor.phone,
        speciality: doctor.speciality,
        isVerified: doctor.isVerified,
        isApproved: doctor.isApproved,
        profilePhoto: doctor.profilePhoto,
        role: doctor.role,
      },
    });
  } catch (error) {
    console.error(`❌ Doctor Login Error:`, error);
    res.status(500).json({
      success: false,
      error: 'Server error occurred during login',
    });
  }
};

/**
 * @desc    Admin Panel Login
 * @route   POST /api/auth/admin-login
 * @access  Public
 */
exports.adminLogin = async (req, res) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({
        success: false,
        error: 'Please enter both Login ID and Password',
      });
    }

    const cleanEmail = email.trim().toLowerCase();

    // Verify Admin credentials from environment config
    const adminEmail = process.env.ADMIN_EMAIL;
    const adminPassword = process.env.ADMIN_PASSWORD;

    if (!adminEmail || !adminPassword) {
      console.error('❌ ADMIN_EMAIL or ADMIN_PASSWORD not configured in .env');
      return res.status(500).json({
        success: false,
        error: 'Admin login is not configured. Contact system administrator.',
      });
    }

    if (cleanEmail === adminEmail.trim().toLowerCase() && password === adminPassword) {
      const token = signToken({ id: 'admin-12032', role: 'admin' });
      return res.status(200).json({
        success: true,
        token,
        admin: {
          email: adminEmail,
          name: process.env.ADMIN_NAME || 'Super Admin Mitra',
          role: 'admin',
        },
      });
    }

    res.status(400).json({
      success: false,
      error: 'Invalid admin ID or password credentials',
    });
  } catch (error) {
    console.error(`❌ Admin Login Error:`, error);
    res.status(500).json({
      success: false,
      error: 'Server error occurred during login',
    });
  }
};
