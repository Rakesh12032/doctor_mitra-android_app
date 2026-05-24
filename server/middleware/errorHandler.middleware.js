/**
 * Global Error Handler Middleware
 */
const errorHandler = (err, req, res, next) => {
  let error = { ...err };
  error.message = err.message;

  // Log to console in development mode
  console.error(`❌ Error caught by Middleware:`, {
    message: err.message,
    name: err.name,
    stack: err.stack,
  });

  // Mongoose Bad ObjectId Error (CastError)
  if (err.name === 'CastError') {
    const message = `Resource not found with id of ${err.value}`;
    error = { status: 44, message };
  }

  // Mongoose Duplicate Key Error (11000)
  if (err.code === 11000) {
    const message = 'Duplicate field value entered. Please try another value.';
    error = { status: 400, message };
  }

  // Mongoose Validation Error (ValidationError)
  if (err.name === 'ValidationError') {
    const message = Object.values(err.errors).map((val) => val.message).join(', ');
    error = { status: 400, message };
  }

  // JWT Token Invalid
  if (err.name === 'JsonWebTokenError') {
    const message = 'Invalid authorization token.';
    error = { status: 401, message };
  }

  // JWT Token Expired
  if (err.name === 'TokenExpiredError') {
    const message = 'Authorization session expired. Please login again.';
    error = { status: 401, message };
  }

  res.status(error.status || err.status || 500).json({
    success: false,
    message: error.message || 'Internal Server Error',
    error: process.env.NODE_ENV === 'development' ? err.stack : undefined,
  });
};

module.exports = errorHandler;
