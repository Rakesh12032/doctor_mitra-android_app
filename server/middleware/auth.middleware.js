const jwt = require('jsonwebtoken');
const User = require('../models/User');
const Doctor = require('../models/Doctor');

/**
 * Protect routes - Verifies JWT from Authorization header and injects authenticated user.
 */
exports.protect = async (req, res, next) => {
  try {
    let token;

    if (
      req.headers.authorization &&
      req.headers.authorization.startsWith('Bearer')
    ) {
      token = req.headers.authorization.split(' ')[1];
    }

    if (!token) {
      return res.status(401).json({
        success: false,
        message: 'Not authorized to access this route. Please login first.',
      });
    }

    // Verify token
    const decoded = jwt.verify(token, process.env.JWT_SECRET);

    // In-app admin bypass checking
    if (decoded.role === 'admin') {
      req.user = { id: decoded.id, role: 'admin', name: 'Super Admin' };
      return next();
    }

    // Fetch user or doctor from database
    if (decoded.role === 'patient') {
      const user = await User.findById(decoded.id);
      if (!user) {
        return res.status(401).json({
          success: false,
          message: 'User session no longer exists. Please re-authenticate.',
        });
      }
      if (!user.isActive) {
        return res.status(403).json({
          success: false,
          message: 'Your user profile has been suspended.',
        });
      }
      req.user = user;
    } else if (decoded.role === 'doctor') {
      const doctor = await Doctor.findById(decoded.id);
      if (!doctor) {
        return res.status(401).json({
          success: false,
          message: 'Doctor session no longer exists. Please re-login.',
        });
      }
      if (!doctor.isActive) {
        return res.status(403).json({
          success: false,
          message: 'Your doctor profile has been suspended.',
        });
      }
      req.user = doctor;
    }

    next();
  } catch (error) {
    console.error(`❌ Authentication Middleware Error:`, error.message);
    return res.status(401).json({
      success: false,
      message: 'Invalid or expired authorization token.',
    });
  }
};

/**
 * Protect temp routes - Verifies JWT containing new user signup session (tempPhone).
 */
exports.protectTemp = async (req, res, next) => {
  try {
    let token;

    if (
      req.headers.authorization &&
      req.headers.authorization.startsWith('Bearer')
    ) {
      token = req.headers.authorization.split(' ')[1];
    }

    if (!token) {
      return res.status(401).json({
        success: false,
        message: 'Not authorized. Missing session token.',
      });
    }

    // Verify token
    const decoded = jwt.verify(token, process.env.JWT_SECRET);

    if (!decoded.isNewUser || !decoded.phone) {
      return res.status(401).json({
        success: false,
        message: 'Invalid registration session token.',
      });
    }

    req.tempPhone = decoded.phone;
    next();
  } catch (error) {
    console.error(`❌ Temp Authentication Middleware Error:`, error.message);
    return res.status(401).json({
      success: false,
      message: 'Registration session expired or invalid.',
    });
  }
};
