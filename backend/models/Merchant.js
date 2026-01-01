const mongoose = require("mongoose");

const merchantSchema = new mongoose.Schema({
  name: { type: String, required: true },
  category: { type: String, required: true },
  address: String,
  location: {
    lat: Number,
    lng: Number
  },
  isApproved: { type: Boolean, default: false },
  isActive: { type: Boolean, default: true }, // ✅ ADD
  qrToken: { type: String, required: true }
}, { timestamps: true });


module.exports = mongoose.model("Merchant", merchantSchema);
