const { getIO } = require("./socket");

exports.emitNewMessage = (userId, message) => {
  const io = getIO();
  io.to(userId.toString()).emit("new_message", message);
};

exports.emitRemoveMessage = (userId, messageId) => {
  const io = getIO();
  io.to(userId.toString()).emit("remove_message", messageId);
};
