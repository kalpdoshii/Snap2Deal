const mongoose = require("mongoose");

const userCouponSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: "User" },
  couponId: { type: mongoose.Schema.Types.ObjectId, ref: "Coupon" },
  status: { type: String, default: "ACTIVE" }, // ACTIVE, USED
  usedAt: Date
}, { timestamps: true });

module.exports = mongoose.model("UserCoupon", userCouponSchema);
