const express = require("express");
const Razorpay = require("razorpay");
const crypto = require("crypto");
const authMiddleware = require("../middlewares/authMiddleware");
const User = require("../models/User");

const router = express.Router();

const razorpay = new Razorpay({
  key_id: process.env.RAZORPAY_KEY_ID,
  key_secret: process.env.RAZORPAY_KEY_SECRET,
});

// 1️⃣ CREATE ORDER
router.post("/create-order", authMiddleware, async (req, res) => {
  const { amount } = req.body;

  const order = await razorpay.orders.create({
    amount: amount * 100, // ₹ → paise
    currency: "INR",
    receipt: `snap2deal_${Date.now()}`,
  });

  res.json(order);
});

// 2️⃣ VERIFY PAYMENT + ACTIVATE SUBSCRIPTION
router.post("/verify", authMiddleware, async (req, res) => {
  const {
    razorpay_order_id,
    razorpay_payment_id,
    razorpay_signature,
  } = req.body;

  const body = razorpay_order_id + "|" + razorpay_payment_id;

  const expectedSignature = crypto
    .createHmac("sha256", process.env.RAZORPAY_KEY_SECRET)
    .update(body)
    .digest("hex");

  if (expectedSignature !== razorpay_signature) {
    return res.status(400).json({ message: "Invalid signature" });
  }

  // ✅ ACTIVATE SUBSCRIPTION (30 days)
  const expiry = new Date();
  expiry.setDate(expiry.getDate() + 30);

  await User.findByIdAndUpdate(req.user._id, {
    subscriptionExpiry: expiry,
  });

  res.json({ message: "Subscription activated", expiry });
});

module.exports = router;
