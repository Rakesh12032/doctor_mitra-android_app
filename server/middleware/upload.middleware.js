const multer = require('multer');

// Configure memory storage to allow buffering files before Cloudinary uploads
const storage = multer.memoryStorage();

// File filter check for allowed mime types
const fileFilter = (req, file, cb) => {
  const allowedTypes = ['image/jpeg', 'image/jpg', 'image/png', 'application/pdf'];
  
  if (allowedTypes.includes(file.mimetype)) {
    cb(null, true);
  } else {
    cb(new Error('Invalid file type. Only JPG, JPEG, PNG images and PDF documents are allowed.'), false);
  }
};

const upload = multer({
  storage: storage,
  limits: {
    fileSize: 10 * 1024 * 1024, // 10MB maximum limit
  },
  fileFilter: fileFilter,
});

module.exports = upload;
