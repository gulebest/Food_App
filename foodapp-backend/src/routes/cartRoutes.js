const express = require("express");
const router = express.Router();
const auth = require("../middleware/auth");
const {
  placeOrder,
  getMyOrders,
  getOrderById,
} = require("../controllers/orderController");

// IMPORTANT: order matters
router.post("/place", auth, placeOrder);

// 🔥 THIS IS WHAT FLUTTER CALLS
router.get("/", auth, getMyOrders); // ✅ FIXED PATH

router.get("/:id", auth, getOrderById);

module.exports = router;
