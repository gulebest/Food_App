// src/controllers/productController.js
const Product = require('../models/Product');

exports.list = async (req, res) => {
  try {
    const { q, category } = req.query;
    const filter = {};

    if (category && category !== 'All') filter.category = category;
    if (q) filter.$or = [
      { name: new RegExp(q, 'i') },
      { description: new RegExp(q, 'i') },
      { category: new RegExp(q, 'i') }
    ];

    const products = await Product.find(filter).sort({ createdAt: -1 }).limit(200);
    res.json(products);
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
};

exports.getById = async (req, res) => {
  try {
    const p = await Product.findById(req.params.id);
    if (!p) return res.status(404).json({ message: 'Product not found' });
    res.json(p);
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
};
