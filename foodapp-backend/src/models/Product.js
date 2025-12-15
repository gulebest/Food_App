const mongoose = require("mongoose");

const productSchema = new mongoose.Schema(
  {
    name: {
      type: String,
      required: true,
      trim: true,
    },

    description: {
      type: String,
      default: "",
    },

    // ✅ STORE IMAGE URL (placeholder allowed)
    image: {
      type: String,
      default: "https://via.placeholder.com/300",
    },

    price: {
      type: Number,
      required: true,
    },

    rating: {
      type: Number,
      default: 4.0,
    },

    calories: {
      type: String,
      default: "",
    },

    // ✅ MATCH UI CATEGORIES
    category: {
      type: String,
      enum: ["Combos", "Sliders", "Classics"],
      default: "Classics",
    },

    isAvailable: {
      type: Boolean,
      default: true,
    },
  },
  { timestamps: true }
);

module.exports = mongoose.model("Product", productSchema);
