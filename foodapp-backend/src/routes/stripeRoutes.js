import express from "express";
import Stripe from "stripe";
import Order from "../models/Order.js";
import Product from "../models/Product.js";
import bodyParser from "body-parser";

const router = express.Router();
const stripe = new Stripe(process.env.STRIPE_SECRET_KEY);

// Stripe requires RAW body
router.post(
  "/webhook",
  bodyParser.raw({ type: "application/json" }),
  async (req, res) => {
    const sig = req.headers["stripe-signature"];

    let event;
    try {
      event = stripe.webhooks.constructEvent(
        req.body,
        sig,
        process.env.STRIPE_WEBHOOK_SECRET
      );
    } catch (err) {
      return res.status(400).send(`Webhook Error: ${err.message}`);
    }

    if (event.type === "payment_intent.succeeded") {
      const intent = event.data.object;

      const {
        userId,
        address,
        cartItems,
      } = intent.metadata;

      // 🚨 DUPLICATE PROTECTION
      const existingOrder = await Order.findOne({
        paymentIntentId: intent.id,
      });
      if (existingOrder) {
        return res.json({ received: true });
      }

      // Convert cart items to Mongo ObjectIds
      const items = [];
      let total = 0;

      for (const item of JSON.parse(cartItems)) {
        const product = await Product.findById(item.productId);
        if (!product) continue;

        items.push({
          product: product._id,
          quantity: item.quantity,
          price: product.price,
        });

        total += product.price * item.quantity;
      }

      await Order.create({
        user: userId,
        items,
        totalAmount: total,
        deliveryAddress: address,
        paymentIntentId: intent.id,
      });
    }

    res.json({ received: true });
  }
);

export default router;
