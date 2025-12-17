const express = require("express");
const router = express.Router();
const auth = require("../middleware/auth");
const {
  getMyMessages,
  sendMessage,
  getAllConversations,
  getConversationByUser,
  adminReply,
} = require("../controllers/supportController");

// ===============================
// USER ROUTES
// ===============================
router.get("/my", auth, getMyMessages);
router.post("/send", auth, sendMessage);

// ===============================
// ADMIN ROUTES
// ===============================
router.get("/admin", auth, getAllConversations);
router.get("/admin/:userId", auth, getConversationByUser);
router.post("/admin/reply", auth, adminReply);

module.exports = router;
