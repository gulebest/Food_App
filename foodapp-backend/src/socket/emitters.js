const { getIO } = require("./socket");

exports.emitNewMessage = (receiverId, message) => {
  const io = getIO();

  // ✅ emit ONLY to receiver (not sender)
  io.to(receiverId.toString()).emit("new_message", message);
};

exports.emitRemoveMessage = (receiverId, messageId) => {
  const io = getIO();
  io.to(receiverId.toString()).emit("remove_message", messageId);
};
