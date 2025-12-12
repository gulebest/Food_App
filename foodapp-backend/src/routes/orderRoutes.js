const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth');
const orderController = require('../controllers/orderController');

router.post('/place', auth, orderController.placeOrder);
router.get('/', auth, orderController.myOrders);
router.get('/:id', auth, orderController.getById);

module.exports = router;
