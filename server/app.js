const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const compression = require('compression');
const mongoSanitize = require('express-mongo-sanitize');
const xss = require('xss-clean');
const dotenv = require('dotenv');

// Load environment variables
dotenv.config();

const app = express();

// Set security HTTP headers
app.use(helmet());

// Enable CORS
app.use(cors());

// Development logging
if (process.env.NODE_ENV === 'development') {
  app.use(morgan('dev'));
} else {
  app.use(morgan('combined'));
}

// Limit request sizes (Body parsers)
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Data sanitization against NoSQL query injection
app.use(mongoSanitize());

// Data sanitization against XSS (Cross Site Scripting)
app.use(xss());

// Compress all responses
app.use(compression());

// Serve static uploads folder locally
const path = require('path');
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

// Base API Healthcheck route
app.get('/api/health', (req, res) => {
  res.status(200).json({
    success: true,
    message: 'Doctor Mitra Backend API is fully operational 🚀',
    timestamp: new Date().toISOString(),
    env: process.env.NODE_ENV,
  });
});

// Auth Routes
app.use('/api/auth', require('./routes/auth.routes'));

// Doctor Routes
app.use('/api/doctors', require('./routes/doctor.routes'));

// Appointment Routes
app.use('/api/appointments', require('./routes/appointment.routes'));

// Payment Routes
app.use('/api/payments', require('./routes/payment.routes'));

// Health Record Routes
app.use('/api/health-records', require('./routes/healthRecord.routes'));

// Consultation Routes
app.use('/api/consultations', require('./routes/consultation.routes'));

// Prescription Routes
app.use('/api/prescriptions', require('./routes/prescription.routes'));

// Review Routes
app.use('/api/reviews', require('./routes/review.routes'));

// Admin Routes
app.use('/api/admin', require('./routes/admin.routes'));

// Notification Routes
app.use('/api/notifications', require('./routes/notification.routes'));

// Hospital Routes
app.use('/api/hospitals', require('./routes/hospital.routes'));

// Ambulance Routes
app.use('/api/ambulances', require('./routes/ambulance.routes'));

// Article Routes
app.use('/api/articles', require('./routes/article.routes'));

// ABHA Routes
app.use('/api/abha', require('./routes/abha.routes'));

// Medicine Routes
app.use('/api/medicines', require('./routes/medicine.routes'));

// Order Routes
app.use('/api/orders', require('./routes/order.routes'));

// State-Sync Compatibility Routes (Flutter legacy bridge)
app.use('/api/state', require('./routes/stateSync.routes'));
app.use('/api/actions', require('./routes/stateSync.routes'));


// Global Error Handler Middleware
const errorHandler = require('./middleware/errorHandler.middleware');
app.use(errorHandler);

module.exports = app;
