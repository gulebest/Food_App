// src/middleware/auth.js
const jwt = require('jsonwebtoken');

function auth(req, res, next) {
  const header = req.header('Authorization') || req.header('authorization');
  if (!header) return res.status(401).json({ message: 'No token, authorization denied' });

  // header should be "Bearer <token>"
  const parts = header.split(' ');
  const token = parts.length === 2 ? parts[1] : parts[0];

  try {
    const secret = process.env.JWT_SECRET;
    const decoded = jwt.verify(token, secret);
    req.user = decoded.user;
    next();
  } catch (err) {
    return res.status(401).json({ message: 'Invalid token' });
  }
}

module.exports = auth;
