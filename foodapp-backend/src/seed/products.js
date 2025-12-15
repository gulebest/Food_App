const mongoose = require("mongoose");
const Product = require("../models/Product");
require("dotenv").config();

const products = [
  {
    name: "Cheeseburger Wendy's Burger",
    description: "Classic cheeseburger with melted cheese",
    image: "https://via.placeholder.com/300?text=Burger",
    price: 8.24,
    rating: 4.9,
    calories: "320 kcal",
    category: "Classics",
  },
  {
    name: "Hamburger Veggie Burger",
    description: "Healthy veggie burger with fresh vegetables",
    image: "https://via.placeholder.com/300?text=Veggie+Burger",
    price: 9.99,
    rating: 4.8,
    calories: "280 kcal",
    category: "Sliders",
  },
  {
    name: "Hamburger Chicken Burger",
    description: "Grilled chicken burger with lettuce",
    image: "https://via.placeholder.com/300?text=Chicken+Burger",
    price: 12.48,
    rating: 4.6,
    calories: "350 kcal",
    category: "Combos",
  },
  {
    name: "Fried Chicken Burger",
    description: "Crispy fried chicken with sauce",
    image: "https://via.placeholder.com/300?text=Fried+Chicken",
    price: 26.99,
    rating: 4.5,
    calories: "500 kcal",
    category: "Classics",
  },
];

async function seed() {
  try {
    await mongoose.connect(process.env.MONGO_URI);
    await Product.deleteMany();
    await Product.insertMany(products);

    console.log("✅ Products seeded successfully");
    process.exit();
  } catch (err) {
    console.error("❌ Seeding error:", err);
    process.exit(1);
  }
}

seed();
