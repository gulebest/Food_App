// src/middleware/auth.js
const jwt = require("jsonwebtoken");

function auth(req, res, next) {
  const header = req.header("Authorization") || req.header("authorization");

  if (!header || !header.startsWith("Bearer ")) {
    return res.status(401).json({ message: "No token, authorization denied" });
  }

  try {
    const token = header.split(" ")[1];
    const decoded = jwt.verify(token, process.env.JWT_SECRET);

    // ✅ FIX: token contains { id }, not { user }
    req.user = { id: decoded.id };

    next();
  } catch (err) {
    console.error("Auth middleware error:", err);
    return res.status(401).json({ message: "Invalid token" });
  }
}

module.exports = auth;
