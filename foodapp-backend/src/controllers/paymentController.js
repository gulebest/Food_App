const Stripe = require("stripe");
const stripe = new Stripe(process.env.STRIPE_SECRET_KEY);

exports.createPaymentIntent = async (req, res) => {
  try {
    const { amount, items, address, userId } = req.body;

    if (!amount || amount <= 0) {
      return res.status(400).json({ message: "Invalid amount" });
    }

    const paymentIntent = await stripe.paymentIntents.create({
      amount, // amount in cents
      currency: "usd",
      automatic_payment_methods: { enabled: true },

      // 🧠 VERY IMPORTANT — metadata used later by webhook
      metadata: {
        userId: userId || "",
        address: address || "",
        cartItems: items ? JSON.stringify(items) : "[]",
      },
    });

    res.status(200).json({
      clientSecret: paymentIntent.client_secret,
    });
  } catch (err) {
    console.error("Stripe Error:", err);
    res.status(500).json({ message: err.message });
  }
};
