const express = require('express');
const router = express.Router();
const {
  uploadHealthRecord,
  getMyHealthRecords,
  getHealthRecordById,
  shareRecordWithDoctor,
  deleteHealthRecord,
} = require('../controllers/healthRecord.controller');
const { protect } = require('../middleware/auth.middleware');
const upload = require('../middleware/upload.middleware');

// All health records require active patient/doctor JWT session protect
router.use(protect);

// Upload and list vault records
router.post('/', upload.single('file'), uploadHealthRecord);
router.get('/', getMyHealthRecords);

// Manage single record elements
router.get('/:id', getHealthRecordById);
router.post('/:id/share', shareRecordWithDoctor);
router.delete('/:id', deleteHealthRecord);

module.exports = router;
