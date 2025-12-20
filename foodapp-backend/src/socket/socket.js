const { Server } = require("socket.io");

let io;

exports.init = (server) => {
  io = new Server(server, {
    cors: { origin: "*" },
  });

  io.on("connection", (socket) => {
    console.log("🟢 Socket connected:", socket.id);

    socket.on("join", (userId) => {
      socket.join(userId);
      socket.userId = userId; // ✅ track owner
    });

    socket.on("typing", (targetId) => {
      socket.to(targetId).emit("typing");
    });

    socket.on("stop_typing", (targetId) => {
      socket.to(targetId).emit("stop_typing");
    });

    socket.on("disconnect", () => {
      console.log("🔴 Socket disconnected:", socket.id);
    });
  });

  return io;
};

exports.getIO = () => {
  if (!io) throw new Error("Socket.io not initialized");
  return io;
};
