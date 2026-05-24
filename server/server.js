const app = require('./app');
const connectDB = require('./config/db');

// Connect to MongoDB Atlas (Mongoose Connection with Retry Logic)
connectDB();

const PORT = process.env.PORT || 5000;
const NODE_ENV = process.env.NODE_ENV || 'development';

const server = app.listen(PORT, () => {
  console.log(`🚀 Doctor Mitra Server running in ${NODE_ENV} mode on port ${PORT}`);
});

// Handle unhandled promise rejections safely
process.on('unhandledRejection', (err, promise) => {
  console.error(`❌ Unhandled Rejection Error: ${err.message}`);
  // Close server & exit process
  server.close(() => process.exit(1));
});
