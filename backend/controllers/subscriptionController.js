const Subscription = require("../models/Subscription");
const User = require("../models/User");
const Coupon = require("../models/Coupon");
const UserCoupon = require("../models/UserCoupon");

// Get all plans
exports.getSubscriptions = async (req, res) => {
  const plans = await Subscription.find();
  res.json(plans);
};

// Subscribe user (mock payment success)
exports.subscribeUser = async (req, res) => {
  const { userId, subscriptionId } = req.body;

  const user = await User.findById(userId);
  const subscription = await Subscription.findById(subscriptionId);

  if (!user || !subscription) {
    return res.status(404).json({ message: "Invalid user or plan" });
  }

  user.subscriptionId = subscriptionId;
  await user.save();

  // Assign coupons
  const coupons = await Coupon.find().limit(subscription.couponLimit);

  for (let coupon of coupons) {
    await UserCoupon.create({
      userId: user._id,
      couponId: coupon._id
    });
  }

  res.json({
    message: "Subscription activated",
    couponsAssigned: coupons.length
  });
};

exports.redeemCoupon = async (req, res) => {
  const { userId, vendorId, couponType } = req.body;

  try {
    const coupon = await UserCoupon.findOne({
      userId,
      vendorId,
      couponType,
      status: "ACTIVE",
    });

    if (!coupon) {
      return res.status(400).json({ message: "Coupon already used or invalid" });
    }

    coupon.status = "USED";
    await coupon.save();

    res.json({ message: "Coupon redeemed" });
  } catch (err) {
    res.status(500).json({ message: "Redeem failed" });
  }
};
