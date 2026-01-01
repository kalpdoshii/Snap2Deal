const mongoose = require("mongoose");

const userSchema = new mongoose.Schema({
  phone: { type: String, required: true, unique: true , trim: true },
  name: { type: String, required: true , trim: true},
  email: { type: String, trim: true , lowercase: true , default: null },
  isVerified: { type: Boolean, default: false },
  subscriptionId: { type: mongoose.Schema.Types.ObjectId, ref: "Subscription" , default: null },
  subscriptionExpiry: { type: Date , default: null }
}, { timestamps: true });

module.exports = mongoose.model("User", userSchema);
