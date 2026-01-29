const mongoose = require("mongoose");

const userCouponSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: "User",required: true },
  couponId: { type: mongoose.Schema.Types.ObjectId, ref: "Coupon", required: true },
  merchantId: { type: mongoose.Schema.Types.ObjectId, ref: "Merchant",required: true },
  status: { type: String,enum : ["USED"], default: "USED" }, // ACTIVE, USED
  usedAt: Date,
  discountValue: { type: Number, default: 0 } // money saved
}, { timestamps: true });

module.exports = mongoose.model("UserCoupon", userCouponSchema);
