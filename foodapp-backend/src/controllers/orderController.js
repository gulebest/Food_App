// src/controllers/orderController.js
const Order = require('../models/Order');
const Cart = require('../models/Cart');
const Product = require('../models/Product');

// Place a new order
exports.placeOrder = async (req, res) => {
  try {
    const { deliveryAddress } = req.body;

    // Find user's cart
    const cart = await Cart.findOne({ user: req.user.id }).populate('items.product');
    if (!cart || cart.items.length === 0) {
      return res.status(400).json({ message: 'Cart is empty' });
    }

    // Prepare order items
    const orderItems = cart.items.map(item => ({
      product: item.product._id,
      quantity: item.qty,
      price: item.product.price
    }));

    // Calculate total amount
    const totalAmount = orderItems.reduce((sum, item) => sum + item.quantity * item.price, 0);

    // Create order
    const order = new Order({
      user: req.user.id,
      items: orderItems,
      totalAmount,
      deliveryAddress
    });

    await order.save();

    // Clear the cart
    cart.items = [];
    cart.subtotal = 0;
    await cart.save();

    res.status(201).json({ message: 'Order placed successfully', order });
  } catch (error) {
    console.error('Place Order Error:', error);
    res.status(500).json({ message: 'Server error' });
  }
};

// Get all orders of the logged-in user
exports.myOrders = async (req, res) => {
  try {
    const orders = await Order.find({ user: req.user.id }).sort({ createdAt: -1 }).populate('items.product');
    res.json(orders);
  } catch (error) {
    console.error('Get My Orders Error:', error);
    res.status(500).json({ message: 'Server error' });
  }
};

// Get a single order by ID
exports.getById = async (req, res) => {
  try {
    const order = await Order.findOne({ _id: req.params.id, user: req.user.id }).populate('items.product');

    if (!order) {
      return res.status(404).json({ message: 'Order not found' });
    }

    res.json(order);
  } catch (error) {
    console.error('Get Order By ID Error:', error);
    res.status(500).json({ message: 'Server error' });
  }
};
