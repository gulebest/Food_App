const Product = require("../models/Product");

// =========================
// GET ALL PRODUCTS
// =========================
exports.list = async (req, res) => {
  try {
    const products = await Product.find({ isAvailable: true })
      .sort({ createdAt: -1 });

    res.status(200).json(products); // ✅ _id INCLUDED
  } catch (error) {
    console.error("Product List Error:", error);
    res.status(500).json({ message: "Server error" });
  }
};

// =========================
// GET PRODUCT BY ID
// =========================
exports.getById = async (req, res) => {
  try {
    const product = await Product.findById(req.params.id);

    if (!product) {
      return res.status(404).json({ message: "Product not found" });
    }

    res.status(200).json(product);
  } catch (error) {
    console.error("Product GetById Error:", error);
    res.status(500).json({ message: "Server error" });
  }
};
