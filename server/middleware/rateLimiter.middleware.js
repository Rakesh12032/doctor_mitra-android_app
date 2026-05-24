const rateLimit = require('express-rate-limit');

// Rate limit configuration for security OTP generation endpoints (max 5 requests per 10 mins)
exports.otpLimiter = rateLimit({
  windowMs: 10 * 60 * 1000, // 10 minutes
  max: 5,
  message: {
    success: false,
    message: 'Too many OTP requests from this IP. Please try again after 10 minutes.',
  },
  standardHeaders: true,
  legacyHeaders: false,
});

// General public API limiter (max 100 requests per 15 mins)
exports.apiLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100,
  message: {
    success: false,
    message: 'Too many requests from this IP. Please try again after 15 minutes.',
  },
  standardHeaders: true,
  legacyHeaders: false,
});
