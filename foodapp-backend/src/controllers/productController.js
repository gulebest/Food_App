const Product = require('../models/Product');

exports.list = async (req, res) => {
  try {
    const products = await Product.find().sort({ createdAt: -1 });
    res.json(products);
  } catch (error) {
    console.error("Product List Error:", error);
    res.status(500).json({ message: "Server error" });
  }
};

exports.getById = async (req, res) => {
  try {
    const product = await Product.findById(req.params.id);
    if (!product) return res.status(404).json({ message: "Product not found" });
    res.json(product);
  } catch (error) {
    console.error("Product GetById Error:", error);
    res.status(500).json({ message: "Server error" });
  }
};
