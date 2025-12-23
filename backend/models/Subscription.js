const mongoose = require("mongoose");

const subscriptionSchema = new mongoose.Schema({
  name: String,
  durationDays: Number,
  price: Number,
  couponLimit: Number
});

module.exports = mongoose.model("Subscription", subscriptionSchema);
