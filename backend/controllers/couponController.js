const Coupon = require("../models/Coupon");
const UserCoupon = require("../models/UserCoupon");

exports.getCouponsByMerchant = async (req, res) => {
  const { merchantId } = req.params;
  const { userId } = req.query;

  try {
    const coupons = await Coupon.find({ merchantId });

    // 🔥 Find used coupons for this user
    let usedCouponIds = [];
    if (userId) {
      const usedCoupons = await UserCoupon.find({ userId });
      usedCouponIds = usedCoupons.map(c => c.couponId.toString());
    }

    // 🔥 Remove used coupons
    const availableCoupons = coupons.filter(
      c => !usedCouponIds.includes(c._id.toString())
    );

    res.json({
      isSubscribed: true, // already handled earlier
      coupons: availableCoupons,
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "Failed to load coupons" });
  }
};
