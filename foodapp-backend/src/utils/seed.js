// src/utils/seed.js
require('dotenv').config();
const connectDB = require('../config/db');
const Product = require('../models/Product');

const PRODUCTS = [
  {
    name: 'Classic Burger',
    category: 'Classics',
    description: 'Juicy beef burger with lettuce, tomato and our special sauce.',
    image: 'assets/burger.png',
    price: 6.99,
    calories: '420 kcal',
    rating: 4.5
  },
  {
    name: 'Fried Chicken Combo',
    category: 'Combos',
    description: 'Two crispy breasts with fries and a drink.',
    image: 'assets/fried_chicken.png',
    price: 12.99,
    calories: '980 kcal',
    rating: 4.7
  },
  {
    name: 'Slider Trio',
    category: 'Sliders',
    description: 'Three mini sliders: beef, chicken and veggie.',
    image: 'assets/sliders.png',
    price: 8.49,
    calories: '650 kcal',
    rating: 4.3
  }
];

async function seed() {
  if (!process.env.MONGODB_URI) {
    console.error('.env MONGODB_URI missing. Create .env from .env.example');
    process.exit(1);
  }

  await connectDB(process.env.MONGODB_URI);
  try {
    await Product.deleteMany({});
    await Product.insertMany(PRODUCTS);
    console.log('Seeded products');
    process.exit(0);
  } catch (err) {
    console.error('Seeding error:', err);
    process.exit(1);
  }
}

seed();
