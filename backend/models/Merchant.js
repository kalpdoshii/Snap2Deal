const mongoose = require("mongoose");

const merchantSchema = new mongoose.Schema(
  {
    name: { type: String, required: true },
    category: {
      type: String,
      required: true,
      enum: ["Restaurant", "Cafe", "Salon", "Shop"],
    },

    address: String,

    location: {
      lat: Number,
      lng: Number,
    },

    // 🖼️ IMAGES
    logoUrl: {
      type: String,
      required: true, // used everywhere
    },

    coverImageUrl: {
      type: String, // used for banners / featured cards
    },

    rating: { type: Number, default: 4 },


    // 🔐 STATUS
    isApproved: { type: Boolean, default: false },
    isActive: { type: Boolean, default: true },

    // 🔑 QR
    qrToken: { type: String, required: true },
  },
  { timestamps: true }
);

module.exports = mongoose.model("Merchant", merchantSchema);
