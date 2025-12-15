const express = require("express");
const router = express.Router();

const auth = require("../middleware/auth");
const {
  placeOrder,
  getMyOrders,
  getOrderById,
} = require("../controllers/orderController");

/*
|--------------------------------------------------------------------------
| ORDER ROUTES
|--------------------------------------------------------------------------
| Base path: /api/orders
| All routes require authentication
*/

/**
 * @route   POST /api/orders/place
 * @desc    Place a new order
 * @access  Private
 */
router.post("/place", auth, placeOrder);

/**
 * @route   GET /api/orders/my
 * @desc    Get all orders for logged-in user
 * @access  Private
 */
router.get("/my", auth, getMyOrders);

/**
 * @route   GET /api/orders/:id
 * @desc    Get single order by ID
 * @access  Private
 */
router.get("/:id", auth, getOrderById);

module.exports = router;
