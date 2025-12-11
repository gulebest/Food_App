// src/routes/orders.js
const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth');
const orderController = require('../controllers/orderController');

// POST /api/orders/place
router.post('/place', auth, orderController.placeOrder);

// GET /api/orders
router.get('/', auth, orderController.myOrders);

// GET /api/orders/:id
router.get('/:id', auth, orderController.getById);

module.exports = router;
