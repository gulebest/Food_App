const mongoose = require("mongoose");

const supportMessageSchema = new mongoose.Schema(
  {
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
    },
    sender: {
      type: String,
      enum: ["user", "support"],
      required: true,
    },
    message: {
      type: String,
      required: true,
    },

    // 🤖 AUTO-REPLY FLAG (LEVEL 1 BOT)
    isAuto: {
      type: Boolean,
      default: false,
    },
  },
  { timestamps: true }
);

module.exports = mongoose.model("SupportMessage", supportMessageSchema);
