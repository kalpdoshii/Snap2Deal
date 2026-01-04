const mongoose = require("mongoose");

const couponSchema = new mongoose.Schema({
  merchantId: { type: mongoose.Schema.Types.ObjectId, ref: "Merchant" },
  title: String,
  description: String,
  type: String,
  isLocked: { type: Boolean, default: true },
  minBillAmount: Number,
  discountValue: Number,
  expiryDate: Date,
  isActive: { type: Boolean, default: true } // ✅ ADD
}, { timestamps: true });


module.exports = mongoose.model("Coupon", couponSchema);
