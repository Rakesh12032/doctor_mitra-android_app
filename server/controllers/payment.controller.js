const crypto = require('crypto');
const Razorpay = require('razorpay');
const Appointment = require('../models/Appointment');
const Payment = require('../models/Payment');
const Notification = require('../models/Notification');
const firebaseAdmin = require('../config/firebase');

// Initialize Razorpay SDK client instance
const getRazorpayInstance = () => {
  if (!process.env.RAZORPAY_KEY_ID || !process.env.RAZORPAY_KEY_SECRET) {
    throw new Error('RAZORPAY_KEY_ID and RAZORPAY_KEY_SECRET must be set in .env');
  }
  return new Razorpay({
    key_id: process.env.RAZORPAY_KEY_ID,
    key_secret: process.env.RAZORPAY_KEY_SECRET,
  });
};

/**
 * @desc    Create a new Razorpay checkout order for an appointment payment
 * @route   POST /api/payments/create-order
 * @access  Private (Patient)
 */
exports.createOrder = async (req, res) => {
  try {
    const { appointmentId } = req.body;

    if (!appointmentId) {
      return res.status(400).json({
        success: false,
        error: 'Please provide appointmentId',
      });
    }

    const appointment = await Appointment.findById(appointmentId);
    if (!appointment) {
      return res.status(404).json({
        success: false,
        error: 'Appointment booking not found',
      });
    }

    // Verify ownership
    if (appointment.patient.toString() !== req.user._id.toString()) {
      return res.status(403).json({
        success: false,
        error: 'Not authorized to make payment for this appointment',
      });
    }

    if (appointment.payment.status === 'successful') {
      return res.status(400).json({
        success: false,
        error: 'Payment for this appointment has already been completed',
      });
    }

    const razorpay = getRazorpayInstance();
    const amountInPaise = Math.round(appointment.payment.amount * 100);

    // If consultation fee is 0, authorize instantly without creating payment order
    if (amountInPaise === 0) {
      appointment.payment.status = 'successful';
      appointment.status = 'confirmed';
      await appointment.save();

      return res.status(200).json({
        success: true,
        free: true,
        message: 'Free appointment confirmed directly with zero fee',
      });
    }

    // Create Order option payloads
    const options = {
      amount: amountInPaise,
      currency: 'INR',
      receipt: appointmentId.toString(),
      notes: {
        patientName: appointment.patientDetails?.name || req.user.name,
        appointmentType: appointment.appointmentType,
      },
    };

    const order = await razorpay.orders.create(options);

    // Save payment log
    await Payment.create({
      user: req.user._id,
      appointment: appointmentId,
      amount: appointment.payment.amount,
      currency: 'INR',
      status: 'created',
      razorpayOrderId: order.id,
      notes: `Order created for ${appointment.appointmentType} consultation`,
    });

    // Update appointment with order ID reference
    appointment.payment.razorpayOrderId = order.id;
    await appointment.save();

    res.status(201).json({
      success: true,
      orderId: order.id,
      amount: order.amount,
      currency: order.currency,
      keyId: process.env.RAZORPAY_KEY_ID,
    });
  } catch (error) {
    console.error('❌ Create Razorpay Order Error:', error);
    res.status(500).json({
      success: false,
      error: 'Server error occurred while creating transaction order',
    });
  }
};

/**
 * @desc    Cryptographically verify Razorpay payment signatures
 * @route   POST /api/payments/verify-payment
 * @access  Private (Patient)
 */
exports.verifyPayment = async (req, res) => {
  try {
    const { razorpayOrderId, razorpayPaymentId, razorpaySignature } = req.body;

    if (!razorpayOrderId || !razorpayPaymentId || !razorpaySignature) {
      return res.status(400).json({
        success: false,
        error: 'Please provide razorpayOrderId, razorpayPaymentId, and razorpaySignature',
      });
    }

    // Cryptographic signature checking
    if (!process.env.RAZORPAY_KEY_SECRET) {
      return res.status(500).json({
        success: false,
        error: 'Payment verification is not configured. Contact support.',
      });
    }
    const shasum = crypto.createHmac('sha256', process.env.RAZORPAY_KEY_SECRET);
    shasum.update(`${razorpayOrderId}|${razorpayPaymentId}`);
    const expectedSignature = shasum.digest('hex');

    const isAuthentic = expectedSignature === razorpaySignature;

    if (!isAuthentic) {
      // Mark transaction failed
      await Payment.findOneAndUpdate(
        { razorpayOrderId },
        { status: 'failed', notes: 'Cryptographic checkout signature check failed' }
      );
      return res.status(400).json({
        success: false,
        error: 'Payment verification failed. Invalid signature.',
      });
    }

    // Find and update payment log record
    const payment = await Payment.findOneAndUpdate(
      { razorpayOrderId },
      {
        status: 'captured',
        razorpayPaymentId,
        razorpaySignature,
      },
      { new: true }
    );

    if (!payment) {
      return res.status(404).json({
        success: false,
        error: 'Associated payment transaction log record not found',
      });
    }

    // Retrieve and update appointment statuses
    const appointment = await Appointment.findById(payment.appointment).populate('doctor');
    if (!appointment) {
      return res.status(404).json({
        success: false,
        error: 'Associated appointment booking not found',
      });
    }

    appointment.payment.status = 'successful';
    appointment.payment.transactionId = razorpayPaymentId;
    appointment.payment.razorpaySignature = razorpaySignature;
    appointment.status = 'confirmed';
    await appointment.save();

    // Trigger alerts & dynamic push updates
    try {
      // Notify Patient
      await Notification.create({
        recipient: appointment.patient,
        recipientType: 'User',
        title: 'Payment Successful 💳',
        message: `Payment of ₹${payment.amount} is successful. Appointment with Doctor ${appointment.doctor?.name || ''} is confirmed!`,
        relatedId: appointment._id,
        relatedModel: 'Appointment',
      });

      // Notify Doctor
      await Notification.create({
        recipient: appointment.doctor._id,
        recipientType: 'Doctor',
        title: 'Consultation Confirmed 🏥',
        message: `Patient ${appointment.patientDetails?.name || ''} booked a slot at ${appointment.timeSlot} on ${appointment.date.toDateString()}. Fee captured.`,
        relatedId: appointment._id,
        relatedModel: 'Appointment',
      });

      if (appointment.doctor.fcmToken) {
        await firebaseAdmin.messaging().send({
          token: appointment.doctor.fcmToken,
          notification: {
            title: 'Consultation Confirmed 🏥',
            body: `Booking confirmed for ${appointment.timeSlot}. Fee collected.`,
          },
        });
      }
    } catch (notifErr) {
      console.warn('⚠️ Push notification warning:', notifErr.message);
    }

    res.status(200).json({
      success: true,
      message: 'Payment verified and appointment confirmed successfully',
      appointment,
    });
  } catch (error) {
    console.error('❌ Verify Razorpay Payment Error:', error);
    res.status(500).json({
      success: false,
      error: 'Server error occurred during payment verification',
    });
  }
};

/**
 * @desc    Razorpay Webhook Handler for async payment status updates
 * @route   POST /api/payments/webhook
 * @access  Public (verified via Razorpay webhook signature)
 */
exports.razorpayWebhook = async (req, res) => {
  try {
    const webhookSecret = process.env.RAZORPAY_WEBHOOK_SECRET;

    // If no webhook secret configured, accept but log warning
    if (!webhookSecret) {
      console.warn('⚠️ RAZORPAY_WEBHOOK_SECRET not configured. Skipping signature verification.');
    } else {
      // Verify webhook signature
      const receivedSignature = req.headers['x-razorpay-signature'];
      if (!receivedSignature) {
        return res.status(400).json({ success: false, error: 'Missing webhook signature header' });
      }

      const expectedSignature = crypto
        .createHmac('sha256', webhookSecret)
        .update(JSON.stringify(req.body))
        .digest('hex');

      if (expectedSignature !== receivedSignature) {
        console.error('❌ Webhook signature mismatch');
        return res.status(400).json({ success: false, error: 'Invalid webhook signature' });
      }
    }

    const event = req.body.event;
    const paymentEntity = req.body.payload?.payment?.entity;

    if (!event || !paymentEntity) {
      return res.status(200).json({ success: true, message: 'No actionable payload' });
    }

    console.log(`📡 Razorpay Webhook: ${event} | Payment ID: ${paymentEntity.id}`);

    const orderId = paymentEntity.order_id;

    switch (event) {
      case 'payment.captured': {
        // Find the payment record
        const payment = await Payment.findOneAndUpdate(
          { razorpayOrderId: orderId },
          {
            status: 'captured',
            razorpayPaymentId: paymentEntity.id,
            notes: `Webhook: Payment captured. Method: ${paymentEntity.method}`,
          },
          { new: true }
        );

        if (payment && payment.appointment) {
          const appointment = await Appointment.findById(payment.appointment).populate('doctor');
          if (appointment && appointment.payment.status !== 'successful') {
            appointment.payment.status = 'successful';
            appointment.payment.transactionId = paymentEntity.id;
            appointment.status = 'confirmed';
            await appointment.save();

            // Create notifications
            try {
              await Notification.create({
                recipient: appointment.patient,
                recipientType: 'User',
                title: 'Payment Confirmed 💳',
                message: `Webhook: Payment of ₹${payment.amount} confirmed. Appointment with Dr. ${appointment.doctor?.name || ''} is booked!`,
                relatedId: appointment._id,
                relatedModel: 'Appointment',
              });

              if (appointment.doctor?.fcmToken) {
                await firebaseAdmin.messaging().send({
                  token: appointment.doctor.fcmToken,
                  notification: {
                    title: 'New Booking Confirmed 🏥',
                    body: `Payment received for ${appointment.timeSlot} slot. Patient: ${appointment.patientDetails?.name || 'Unknown'}`,
                  },
                });
              }
            } catch (notifErr) {
              console.warn('⚠️ Webhook notification warning:', notifErr.message);
            }
          }
        }
        break;
      }

      case 'payment.failed': {
        await Payment.findOneAndUpdate(
          { razorpayOrderId: orderId },
          {
            status: 'failed',
            notes: `Webhook: Payment failed. Reason: ${paymentEntity.error_description || 'Unknown'}`,
          }
        );

        // Update appointment status
        const failedPayment = await Payment.findOne({ razorpayOrderId: orderId });
        if (failedPayment && failedPayment.appointment) {
          await Appointment.findByIdAndUpdate(failedPayment.appointment, {
            'payment.status': 'failed',
            status: 'cancelled',
          });

          await Notification.create({
            recipient: failedPayment.user,
            recipientType: 'User',
            title: 'Payment Failed ❌',
            message: `Payment attempt failed. Reason: ${paymentEntity.error_description || 'Transaction could not be completed'}. Please try again.`,
            relatedId: failedPayment.appointment,
            relatedModel: 'Appointment',
          });
        }
        break;
      }

      case 'refund.processed': {
        const refundEntity = req.body.payload?.refund?.entity;
        if (refundEntity) {
          await Payment.findOneAndUpdate(
            { razorpayPaymentId: refundEntity.payment_id },
            {
              status: 'refunded',
              notes: `Webhook: Refund of ₹${refundEntity.amount / 100} processed.`,
            }
          );
        }
        break;
      }

      default:
        console.log(`ℹ️ Unhandled webhook event: ${event}`);
    }

    // Always return 200 to Razorpay to acknowledge receipt
    res.status(200).json({ success: true, message: `Webhook event '${event}' processed` });
  } catch (error) {
    console.error('❌ Razorpay Webhook Error:', error);
    // Still return 200 to prevent Razorpay from retrying
    res.status(200).json({ success: true, message: 'Webhook received with processing error' });
  }
};
