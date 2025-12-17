const SupportMessage = require("../models/SupportMessage");
const {
  emitNewMessage,
  emitRemoveMessage,
} = require("../socket/emitters");

// ===============================
// USER: GET MY MESSAGES
// ===============================
exports.getMyMessages = async (req, res) => {
  try {
    const messages = await SupportMessage.find({
      userId: req.user.id,
    }).sort({ createdAt: 1 });

    return res.status(200).json(messages);
  } catch (err) {
    console.error("Get support messages error:", err);
    return res.status(500).json({ message: "Server error" });
  }
};

// ===============================
// USER: SEND MESSAGE
// ===============================
exports.sendMessage = async (req, res) => {
  try {
    const { message } = req.body;

    if (!message || !message.trim()) {
      return res.status(400).json({ message: "Message required" });
    }

    // 1️⃣ USER MESSAGE
    const userMessage = await SupportMessage.create({
      userId: req.user.id,
      sender: "user",
      message: message.trim(),
    });

    emitNewMessage(req.user.id, userMessage);

    // 2️⃣ CHECK IF ADMIN EVER REPLIED
    const hasAdminReply = await SupportMessage.exists({
      userId: req.user.id,
      sender: "support",
      isAuto: false,
    });

    let autoReply = null;

    // 3️⃣ AUTO-REPLY (LEVEL 1 BOT)
    if (!hasAdminReply) {
      autoReply = await SupportMessage.create({
        userId: req.user.id,
        sender: "support",
        isAuto: true,
        message:
          "👋 Thanks for contacting support.\nAn admin will reply shortly.",
      });

      emitNewMessage(req.user.id, autoReply);
    }

    return res.status(201).json(
      autoReply ? [userMessage, autoReply] : [userMessage]
    );
  } catch (err) {
    console.error("Send support message error:", err);
    return res.status(500).json({ message: "Server error" });
  }
};

// ===============================
// ADMIN: GET ALL CONVERSATIONS
// ===============================
exports.getAllConversations = async (req, res) => {
  try {
    const conversations = await SupportMessage.aggregate([
      {
        $group: {
          _id: "$userId",
          lastMessage: { $last: "$message" },
          updatedAt: { $last: "$createdAt" },
        },
      },
      { $sort: { updatedAt: -1 } },
    ]);

    return res.status(200).json(conversations);
  } catch (err) {
    console.error("Get all conversations error:", err);
    return res.status(500).json({ message: "Server error" });
  }
};

// ===============================
// ADMIN: GET CONVERSATION BY USER
// ===============================
exports.getConversationByUser = async (req, res) => {
  try {
    const { userId } = req.params;

    const messages = await SupportMessage.find({ userId }).sort({
      createdAt: 1,
    });

    return res.status(200).json(messages);
  } catch (err) {
    console.error("Get conversation error:", err);
    return res.status(500).json({ message: "Server error" });
  }
};

// ===============================
// ADMIN: REPLY TO USER
// ===============================
exports.adminReply = async (req, res) => {
  try {
    const { userId, message } = req.body;

    if (!userId || !message || !message.trim()) {
      return res.status(400).json({ message: "Invalid request" });
    }

    // 🧹 REMOVE AUTO-REPLY
    const autoReply = await SupportMessage.findOneAndDelete({
      userId,
      isAuto: true,
    });

    if (autoReply) {
      emitRemoveMessage(userId, autoReply._id.toString());
    }

    // 🟢 REAL ADMIN MESSAGE
    const reply = await SupportMessage.create({
      userId,
      sender: "support",
      isAuto: false,
      message: message.trim(),
    });

    emitNewMessage(userId, reply);

    return res.status(201).json(reply);
  } catch (err) {
    console.error("Admin reply error:", err);
    return res.status(500).json({ message: "Server error" });
  }
};
