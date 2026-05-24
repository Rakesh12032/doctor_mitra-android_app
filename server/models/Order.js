const mongoose = require('mongoose');

const OrderSchema = new mongoose.Schema(
  {
    patient: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: [true, 'Patient reference is required'],
    },
    items: [
      {
        medicine: {
          type: mongoose.Schema.Types.ObjectId,
          ref: 'Medicine',
          required: [true, 'Medicine reference is required'],
        },
        name: { type: String, required: true },
        quantity: { type: Number, required: true, min: [1, 'Quantity must be at least 1'] },
        price: { type: Number, required: true },
      }
    ],
    totalAmount: {
      type: Number,
      required: [true, 'Total amount is required'],
    },
    deliveryAddress: {
      name: { type: String, required: true },
      phone: { type: String, required: true },
      address: { type: String, required: true },
      city: { type: String, required: true },
      pincode: { type: String, required: true },
    },
    status: {
      type: String,
      enum: ['placed', 'confirmed', 'packed', 'shipped', 'delivered', 'cancelled'],
      default: 'placed',
    },
    payment: {
      method: { type: String, enum: ['online', 'cod'], default: 'cod' },
      status: { type: String, enum: ['pending', 'successful', 'failed', 'refunded'], default: 'pending' },
      transactionId: { type: String, default: '' },
    },
    deliveryPartner: {
      type: String,
      default: 'Mitra Express Delivery',
    },
    trackingId: {
      type: String,
      default: '',
    },
    estimatedDelivery: {
      type: Date,
    },
  },
  {
    timestamps: true,
  }
);

module.exports = mongoose.model('Order', OrderSchema);
