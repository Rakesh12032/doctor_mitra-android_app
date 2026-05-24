const express = require('express');
const router = express.Router();
const {
  placeOrder,
  getPatientOrders,
  getOrderById,
  cancelOrder,
  updateOrderStatus,
} = require('../controllers/order.controller');

router.post('/', placeOrder);
router.get('/patient/:id', getPatientOrders);
router.get('/:id', getOrderById);
router.put('/:id/cancel', cancelOrder);
router.put('/:id/status', updateOrderStatus);

module.exports = router;
