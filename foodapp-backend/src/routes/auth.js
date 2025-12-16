const express = require('express');
const router = express.Router();
const { body } = require('express-validator');

const authController = require('../controllers/authController');
const authMiddleware = require('../middleware/auth');
const upload = require("../middleware/upload");

// ============================
// REGISTER
// ============================
router.post(
  '/register',
  [
    body('name').notEmpty().withMessage('Name is required'),
    body('email').isEmail().withMessage('Enter a valid email'),
    body('phone').optional().isString(),
    body('password')
      .isLength({ min: 6 })
      .withMessage('Password must be at least 6 characters'),
  ],
  authController.register
);

// ============================
// LOGIN
// ============================
router.post(
  '/login',
  [
    body('email').isEmail().withMessage('Enter a valid email'),
    body('password').exists().withMessage('Password is required'),
  ],
  authController.login
);

// ============================
// GET CURRENT USER
// ============================
router.get('/me', authMiddleware, authController.me);

// ============================
// UPDATE PROFILE (NAME / ADDRESS / PASSWORD / AVATAR)
// ============================
// 🔥 NEW — REQUIRED FOR PROFILE PAGE
router.post(
  '/update-profile',
  authMiddleware,
  authController.updateProfile
);
// Update Profile route with multer
router.put(
  "/update-profile",
  authMiddleware,
  upload.single("avatar"),
  authController.updateProfile
);

module.exports = router;
