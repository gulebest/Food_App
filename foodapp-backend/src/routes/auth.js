const express = require('express');
const router = express.Router();
const { body } = require('express-validator');

const authController = require('../controllers/authController');
const authMiddleware = require('../middleware/auth');

router.post(
  '/register',
  [
    body('name').notEmpty().withMessage('Name is required'),
    body('email').isEmail().withMessage('Enter a valid email'),
    body('phone').optional().isString(),
    body('password').isLength({ min: 6 }).withMessage('Password must be at least 6 characters')
  ],
  authController.register
);

router.post(
  '/login',
  [
    body('email').isEmail().withMessage('Enter a valid email'),
    body('password').exists().withMessage('Password is required')
  ],
  authController.login
);

router.get('/me', authMiddleware, authController.me);

module.exports = router;
