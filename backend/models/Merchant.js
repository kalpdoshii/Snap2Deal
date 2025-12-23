const mongoose = require("mongoose");

const merchantSchema = new mongoose.Schema({
  name: { type: String, required: true },
  category: { type: String, required: true }, // restaurant, salon, shop
  address: String,
  location: {
    lat: Number,
    lng: Number
  },
  isApproved: { type: Boolean, default: false },
  qrToken: { type: String, required: true }
}, { timestamps: true });

module.exports = mongoose.model("Merchant", merchantSchema);
