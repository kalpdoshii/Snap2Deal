const mongoose = require("mongoose");

const couponSchema = new mongoose.Schema({
  merchantId: { type: mongoose.Schema.Types.ObjectId, ref: "Merchant" },
  title: String,
  description: String,
  type: String, // B2G1, FLAT, SPECIAL
  minBillAmount: Number,
  discountValue: Number,
  expiryDate: Date
}, { timestamps: true });

module.exports = mongoose.model("Coupon", couponSchema);
