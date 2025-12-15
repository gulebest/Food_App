const Order = require("../models/Order");

// ===============================
// PLACE ORDER
// ===============================
exports.placeOrder = async (req, res) => {
  try {
    const { deliveryAddress, items, totalAmount } = req.body;

    if (!items || items.length === 0) {
      return res
        .status(400)
        .json({ success: false, message: "Cart is empty" });
    }

    const order = await Order.create({
      user: req.user.id,
      items,
      totalAmount,
      deliveryAddress,
      status: "pending",
    });

    res.status(201).json({
      success: true,
      message: "Order placed successfully",
      order,
    });
  } catch (error) {
    console.error("❌ Place Order Error:", error);
    res.status(500).json({
      success: false,
      message: "Server error while placing order",
    });
  }
};

// ===============================
// GET MY ORDERS
// ===============================
exports.getMyOrders = async (req, res) => {
  try {
    const orders = await Order.find({ user: req.user.id })
      .sort({ createdAt: -1 });

    res.json(orders);
  } catch (error) {
    console.error("❌ Get My Orders Error:", error);
    res.status(500).json({ message: "Failed to fetch orders" });
  }
};

// ===============================
// GET ORDER BY ID
// ===============================
exports.getOrderById = async (req, res) => {
  try {
    const order = await Order.findById(req.params.id)
      .populate("items.product");

    if (!order) {
      return res.status(404).json({ message: "Order not found" });
    }

    res.json(order);
  } catch (error) {
    console.error("❌ Get Order By ID Error:", error);
    res.status(500).json({ message: "Failed to fetch order" });
  }
};
