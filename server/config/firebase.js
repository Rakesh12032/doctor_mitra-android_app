const admin = require('firebase-admin');
const fs = require('fs');
const path = require('path');

let firebaseAdmin = null;

try {
  const serviceAccountPath = process.env.FIREBASE_SERVICE_ACCOUNT_PATH || './config/firebase-service-account.json';
  const resolvedPath = path.resolve(__dirname, '..', serviceAccountPath);

  if (fs.existsSync(resolvedPath)) {
    const serviceAccount = require(resolvedPath);
    
    // Check if private_key is placeholder
    if (serviceAccount.private_key.includes('placeholder_key')) {
      console.log('\n⚠️ Firebase Admin SDK: Placeholder key detected. Running in mock messaging mode for development.');
    } else {
      admin.initializeApp({
        credential: admin.credential.cert(serviceAccount),
        projectId: process.env.FIREBASE_PROJECT_ID || serviceAccount.project_id
      });
      firebaseAdmin = admin;
      console.log('📡 Firebase Admin SDK Initialized Successfully!');
    }
  } else {
    console.log('\n⚠️ Firebase Admin SDK: Credentials file not found. Running in mock messaging mode.');
  }
} catch (error) {
  console.warn('\n⚠️ Firebase Admin SDK Initialization Warning:', error.message);
  console.log('Running in mock messaging mode for development.\n');
}

// Fallback Mock Messaging interface so server doesn't crash on invalid keys
if (!firebaseAdmin) {
  firebaseAdmin = {
    messaging: () => ({
      send: async (message) => {
        console.log(`[MOCK FCM MESSAGE SENT]:`, JSON.stringify(message, null, 2));
        return 'mock-message-id-12032';
      },
      sendMulticast: async (payload) => {
        console.log(`[MOCK FCM MULTICAST SENT]:`, JSON.stringify(payload, null, 2));
        return { successCount: payload.tokens.length, failureCount: 0, responses: [] };
      }
    })
  };
}

module.exports = firebaseAdmin;
