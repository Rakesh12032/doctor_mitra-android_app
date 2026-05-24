const mongoose = require('mongoose');

let retryCount = 0;
const MAX_RETRIES = 3;

const connectDB = async () => {
  try {
    const conn = await mongoose.connect(process.env.MONGODB_URI, {
      autoIndex: true,
    });
    console.log(`📡 MongoDB Atlas Connected: ${conn.connection.host}`);
    retryCount = 0; // Reset retries on success
  } catch (error) {
    console.error(`❌ MongoDB Atlas Connection Error: ${error.message}`);
    
    if (retryCount < MAX_RETRIES) {
      retryCount++;
      const delay = retryCount * 3000; // Exponential-like backoff
      console.log(`🔄 Retrying database connection in ${delay / 1000}s... (Attempt ${retryCount}/${MAX_RETRIES})`);
      setTimeout(connectDB, delay);
    } else {
      console.error(`🚨 Max database connection retries (${MAX_RETRIES}) reached. Shutting down...`);
      process.exit(1);
    }
  }
};

module.exports = connectDB;
