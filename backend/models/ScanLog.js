const mongoose = require("mongoose");

const scanLogSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: "User" },
  couponId: { type: mongoose.Schema.Types.ObjectId, ref: "Coupon" },
  merchantId: { type: mongoose.Schema.Types.ObjectId, ref: "Merchant" },
  scannedAt: { type: Date, default: Date.now },
  isValid: Boolean
});

module.exports = mongoose.model("ScanLog", scanLogSchema);
