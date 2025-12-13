const mongoose = require('mongoose');

const productSchema = new mongoose.Schema(
  {
    name: { type: String, required: true },
    category: { type: String, default: 'Classics' },
    description: { type: String, default: '' },
    image: { type: String, default: 'assets/placeholder.png' },
    price: { type: Number, required: true, default: 0 },
    calories: { type: String, default: '' },
    rating: { type: Number, default: 4 },
    createdAt: { type: Date, default: Date.now },
  },
  { versionKey: false }
);

module.exports = mongoose.model('Product', productSchema);
