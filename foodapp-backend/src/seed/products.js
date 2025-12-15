const mongoose = require("mongoose");
const Product = require("../models/Product");
require("dotenv").config();

const products = [
  {
    name: "Cheeseburger Wendy's Burger",
    description: "Classic cheeseburger with melted cheese",
    image: "https://media.istockphoto.com/id/1318936306/photo/shots-of-different-burger-sandwiches-styles.jpg?s=612x612&w=0&k=20&c=K5DEXFD2Aj2iP3DrTCgG9TlOaupM6JglsGo6u0xORqM=",
    price: 8.24,
    rating: 4.9,
    calories: "320 kcal",
    category: "Classics",
  },
  {
    name: "Hamburger Veggie Burger",
    description: "Healthy veggie burger with fresh vegetables",
    image: "https://media.istockphoto.com/id/1318936289/photo/shots-of-different-burger-sandwiches-styles.jpg?s=612x612&w=0&k=20&c=j3nmkLHaYFIAT82yMtkAa-78H0M-rS20ckmxDgPIUpg=",
    price: 9.99,
    rating: 4.8,
    calories: "280 kcal",
    category: "Sliders",
  },
  {
    name: "Hamburger Chicken Burger",
    description: "Grilled chicken burger with lettuce",
    image: "https://media.istockphoto.com/id/2196201563/photo/chicken-burger-with-tomato.jpg?s=612x612&w=0&k=20&c=zjjxSslgf_ot0MqUfgtd636advdof9K0Ge8EVqO81Cg=",
    price: 12.48,
    rating: 4.6,
    calories: "350 kcal",
    category: "Combos",
  },
  {
    name: "Fried Chicken Burger",
    description: "Crispy fried chicken with sauce",
    image: "https://media.istockphoto.com/id/1318936312/photo/shots-of-different-burger-sandwiches-styles.jpg?s=612x612&w=0&k=20&c=a8stiCnlb2MNdp4VKhRMehH_mPNHTqEVM_JVj2RBXAM=",
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
