const mongoose = require("mongoose");

const userSchema = new mongoose.Schema({
  phone: { type: String, required: true, unique: true },
  isVerified: { type: Boolean, default: false },
  role: { type: String, default: "USER" },
  subscriptionId: { type: mongoose.Schema.Types.ObjectId, ref: "Subscription" }
}, { timestamps: true });

module.exports = mongoose.model("User", userSchema);
