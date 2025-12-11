// src/routes/cart.js
const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth');
const cartController = require('../controllers/cartController');

// GET /api/cart
router.get('/', auth, cartController.getCart);

// POST /api/cart/add
router.post('/add', auth, cartController.addItem);

// PUT /api/cart/update
router.put('/update', auth, cartController.updateQty);

// DELETE /api/cart/remove
router.delete('/remove', auth, cartController.removeItem);

module.exports = router;
