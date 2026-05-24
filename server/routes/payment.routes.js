const express = require('express');
const router = express.Router();
const { createOrder, verifyPayment, razorpayWebhook } = require('../controllers/payment.controller');
const { protect } = require('../middleware/auth.middleware');

// Razorpay Webhook (public — verified by signature, must be BEFORE protect)
router.post('/webhook', razorpayWebhook);

// Secure all remaining payment routes
router.use(protect);

router.post('/create-order', createOrder);
router.post('/verify-payment', verifyPayment);

module.exports = router;
