const Cart = require('../models/Cart');
const Product = require('../models/Product');

exports.getCart = async (req, res) => {
  try {
    const cart = await Cart.findOne({ user: req.user.id }).populate("items.product");
    if (!cart) return res.json({ items: [], subtotal: 0 });
    res.json(cart);
  } catch (error) {
    console.error("Get Cart Error:", error);
    res.status(500).json({ message: "Server error" });
  }
};

exports.addToCart = async (req, res) => {
  try {
    const { productId, qty } = req.body;
    const product = await Product.findById(productId);
    if (!product) return res.status(404).json({ message: "Product not found" });

    let cart = await Cart.findOne({ user: req.user.id });
    if (!cart) cart = new Cart({ user: req.user.id, items: [] });

    const existing = cart.items.find(i => i.product.toString() === productId);
    if (existing) existing.qty += qty;
    else cart.items.push({ product: productId, qty, price: product.price });

    cart.subtotal = cart.items.reduce((sum, i) => sum + i.qty * i.price, 0);

    await cart.save();
    await cart.populate("items.product");

    res.json(cart);
  } catch (error) {
    console.error("Add to Cart Error:", error);
    res.status(500).json({ message: "Server error" });
  }
};

exports.updateQty = async (req, res) => {
  try {
    const { productId, qty } = req.body;
    const cart = await Cart.findOne({ user: req.user.id });
    if (!cart) return res.status(404).json({ message: "Cart not found" });

    const item = cart.items.find(i => i.product.toString() === productId);
    if (!item) return res.status(404).json({ message: "Item not found" });

    if (qty <= 0) cart.items = cart.items.filter(i => i.product.toString() !== productId);
    else item.qty = qty;

    cart.subtotal = cart.items.reduce((sum, i) => sum + i.qty * i.price, 0);

    await cart.save();
    await cart.populate("items.product");
    res.json(cart);
  } catch (error) {
    console.error("Update Qty Error:", error);
    res.status(500).json({ message: "Server error" });
  }
};

exports.clearCart = async (req, res) => {
  try {
    const cart = await Cart.findOne({ user: req.user.id });
    if (!cart) return res.json({ message: "Cart empty" });

    cart.items = [];
    cart.subtotal = 0;
    await cart.save();

    res.json({ message: "Cart cleared" });
  } catch (error) {
    console.error("Clear Cart Error:", error);
    res.status(500).json({ message: "Server error" });
  }
};
