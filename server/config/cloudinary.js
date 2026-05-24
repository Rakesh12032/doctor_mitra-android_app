const cloudinary = require('cloudinary').v2;
const fs = require('fs');
const path = require('path');

let isCloudinaryConfigured = false;

// Check if credentials are valid and not default placeholders
const cloudName = process.env.CLOUDINARY_CLOUD_NAME;
const apiKey = process.env.CLOUDINARY_API_KEY;
const apiSecret = process.env.CLOUDINARY_API_SECRET;
const cloudinaryUrl = process.env.CLOUDINARY_URL;

if (
  (cloudName && cloudName !== 'your_cloudinary_cloud_name' &&
   apiKey && apiKey !== 'your_cloudinary_api_key' &&
   apiSecret && apiSecret !== 'your_cloudinary_api_secret') ||
  (cloudinaryUrl && cloudinaryUrl.trim().startsWith('cloudinary://'))
) {
  if (cloudinaryUrl) {
    cloudinary.config();
  } else {
    cloudinary.config({
      cloud_name: cloudName,
      api_key: apiKey,
      api_secret: apiSecret,
    });
  }
  isCloudinaryConfigured = true;
  console.log('📡 Cloudinary SDK Configured and Ready!');
} else {
  console.log('\n⚠️ Cloudinary: Placeholders detected. Files will be saved in local "uploads" folder for testing.');
}

/**
 * Uploads a file buffer to Cloudinary or falls back to local file storage
 * @param {Buffer} fileBuffer - The file buffer from Multer memory storage
 * @param {string} originalName - Original filename
 * @param {string} mimeType - The mimetype of the file
 * @param {string} folder - Destination folder (default: 'doctormitra')
 * @returns {Promise<{url: string, publicId: string}>}
 */
const uploadToCloud = async (fileBuffer, originalName, mimeType, folder = 'doctormitra') => {
  if (isCloudinaryConfigured) {
    return new Promise((resolve, reject) => {
      const stream = cloudinary.uploader.upload_stream(
        { folder: folder, resource_type: 'auto' },
        (error, result) => {
          if (error) {
            console.error('❌ Cloudinary Stream Upload Error:', error);
            return reject(error);
          }
          resolve({
            url: result.secure_url,
            publicId: result.public_id,
          });
        }
      );
      stream.end(fileBuffer);
    });
  } else {
    // Fallback: Save file to local disk under server/uploads/ directory
    try {
      const uploadsDir = path.resolve(__dirname, '..', 'uploads');
      
      // Proactively create uploads directory if it does not exist
      if (!fs.existsSync(uploadsDir)) {
        fs.mkdirSync(uploadsDir, { recursive: true });
      }

      const fileExtension = path.extname(originalName) || (mimeType === 'application/pdf' ? '.pdf' : '.jpg');
      const uniqueFilename = `${Date.now()}-${Math.round(Math.random() * 1e9)}${fileExtension}`;
      const filePath = path.join(uploadsDir, uniqueFilename);

      // Save buffer asynchronously
      await fs.promises.writeFile(filePath, fileBuffer);

      // Return a working relative URL path
      const localUrl = `/uploads/${uniqueFilename}`;
      console.log(`[LOCAL STORAGE FILE SAVED]: ${localUrl}`);

      return {
        url: localUrl,
        publicId: `local-${uniqueFilename}`,
      };
    } catch (localErr) {
      console.error('❌ Local Storage Fallback Upload Error:', localErr);
      throw localErr;
    }
  }
};

module.exports = {
  cloudinary,
  uploadToCloud,
  isCloudinaryConfigured,
};
