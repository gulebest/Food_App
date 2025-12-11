// src/controllers/orderController.js
const Order = require("../models/Order");
const Cart = require("../models/Cart");

exports.createOrder = async (req, res) => {
  try {
    const cart = await Cart.findOne({ user: req.user.id }).populate("items.product");

    if (!cart || cart.items.length === 0)
      return res.status(400).json({ message: "Cart is empty" });

    const newOrder = new Order({
      user: req.user.id,
      items: cart.items.map((i) => ({
        product: i.product._id,
        qty: i.qty,
        price: i.product.price,
      })),
      totalPrice: cart.items.reduce((sum, i) => sum + i.qty * i.product.price, 0),
    });

    await newOrder.save();

    // clear cart after order
    cart.items = [];
    cart.subtotal = 0;
    await cart.save();

    res.status(201).json({ message: "Order placed successfully", order: newOrder });
  } catch (error) {
    console.error("Create Order Error:", error);
    res.status(500).json({ message: "Server error" });
  }
};

// Get all orders for logged-in user
exports.getMyOrders = async (req, res) => {
  try {
    const orders = await Order.find({ user: req.user.id })
      .populate("items.product")
      .sort({ createdAt: -1 });

    res.json(orders);
  } catch (error) {
    console.error("Get Orders Error:", error);
    res.status(500).json({ message: "Server error" });
  }
};

// Get single order by ID
exports.getOrderById = async (req, res) => {
  try {
    const order = await Order.findOne({
      _id: req.params.id,
      user: req.user.id,
    }).populate("items.product");

    if (!order)
      return res.status(404).json({ message: "Order not found" });

    res.json(order);
  } catch (error) {
    console.error("Order By ID Error:", error);
    res.status(500).json({ message: "Server error" });
  }
};
