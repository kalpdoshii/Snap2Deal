const Coupon = require("../models/Coupon");
const UserCoupon = require("../models/UserCoupon");

exports.getCouponsByMerchant = async (req, res) => {
  try {
    const { merchantId } = req.params;
    const user = req.user;

    // 1️⃣ Get coupons already used by this user
    const usedCoupons = await UserCoupon.find({
      userId: user._id,
      status: "USED",
    }).select("couponId");

    const usedCouponIds = usedCoupons.map((c) => c.couponId);

    // 2️⃣ Fetch active & un-used coupons
    const coupons = await Coupon.find({
      merchantId,
      isActive: true,
      expiryDate: { $gte: new Date() },
      _id: { $nin: usedCouponIds },
    });

    // 3️⃣ Check subscription status
    const isSubscribed =
      user.subscriptionExpiry &&
      new Date(user.subscriptionExpiry) > new Date();

    // 4️⃣ Send response
    res.json({
      isSubscribed,
      coupons,
    });
  } catch (error) {
    console.error("❌ getCouponsByMerchant error:", error);
    res.status(500).json({ message: "Failed to fetch coupons" });
  }
};
