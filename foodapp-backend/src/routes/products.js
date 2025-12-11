// src/routes/products.js
const express = require('express');
const router = express.Router();
const productController = require('../controllers/productController');

// GET /api/products
router.get('/', productController.list);

// GET /api/products/:id
router.get('/:id', productController.getById);

module.exports = router;
