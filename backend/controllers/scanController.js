const User = require("../models/User");
const Merchant = require("../models/Merchant");
const Coupon = require("../models/Coupon");
const UserCoupon = require("../models/UserCoupon");
const ScanLog = require("../models/ScanLog");

exports.scanCoupon = async (req, res) => {
  const { userId, couponId, merchantQrToken } = req.body;

  // 1. Validate user
  const user = await User.findById(userId);
  if (!user || !user.isVerified) {
    return res.status(401).json({ message: "Invalid user" });
  }

  // 2. Validate merchant QR
  const merchant = await Merchant.findOne({ qrToken: merchantQrToken });
  if (!merchant || !merchant.isApproved) {
    return res.status(404).json({ message: "Invalid merchant QR" });
  }

  // 3. Validate coupon
  const coupon = await Coupon.findById(couponId);
  if (!coupon) {
    return res.status(404).json({ message: "Invalid coupon" });
  }

  // 4. Check coupon belongs to merchant
  if (coupon.merchantId.toString() !== merchant._id.toString()) {
    return res.status(403).json({ message: "Coupon not valid for this merchant" });
  }

  // 5. Check user coupon
  const userCoupon = await UserCoupon.findOne({
    userId,
    couponId,
    status: "ACTIVE"
  });

  if (!userCoupon) {
    return res.status(409).json({ message: "Coupon already used or not assigned" });
  }

  // 6. Mark coupon as USED
  userCoupon.status = "USED";
  userCoupon.usedAt = new Date();
  await userCoupon.save();

  // 7. Create scan log
  await ScanLog.create({
    userId,
    couponId,
    merchantId: merchant._id,
    isValid: true
  });

  res.json({
    message: "Coupon redeemed successfully 🎉",
    coupon: coupon.title,
    merchant: merchant.name
  });
};
