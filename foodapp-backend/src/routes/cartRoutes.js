const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth');
const cartController = require('../controllers/cartController');

router.get('/', auth, cartController.getCart);
router.post('/add', auth, cartController.addToCart);
router.put('/update', auth, cartController.updateQty);
router.delete('/clear', auth, cartController.clearCart);

module.exports = router;
