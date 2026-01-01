const User = require("../models/User");
const UserCoupon = require("../models/UserCoupon");


exports.updateProfile = async (req, res) => {
  console.log("UPDATE PROFILE HIT");
  console.log("BODY:", req.body);

  const { userId, name, email } = req.body;

  if (!userId || !name) {
    console.log("❌ Missing userId or name");
    return res.status(400).json({
      message: "userId and name are required",
    });
  }

  try {
    const user = await User.findById(userId);

    if (!user) {
      console.log("❌ User not found");
      return res.status(404).json({ message: "User not found" });
    }

    user.name = name;
    user.email = email || null;
    await user.save();

    console.log("✅ Profile updated");

    res.status(200).json({
      message: "Profile updated",
      user,
    });
  } catch (err) {
    console.error("❌ Update profile error:", err);
    res.status(500).json({ message: "Server error" });
  }
};

exports.getProfileStats = async (req, res) => {
  const { userId } = req.params;

  try {
    const totalCoupons = await UserCoupon.countDocuments({ userId });
    const usedCoupons = await UserCoupon.countDocuments({
      userId,
      status: "USED"
    });

    const activeCoupons = totalCoupons - usedCoupons;

    const savingsAgg = await UserCoupon.aggregate([
      { $match: { userId: new mongoose.Types.ObjectId(userId), status: "USED" } },
      { $group: { _id: null, totalSaved: { $sum: "$discountValue" } } }
    ]);

    const totalSaved = savingsAgg[0]?.totalSaved || 0;

    res.json({
      couponsLeft: activeCoupons,
      usedCoupons,
      totalSaved
    });

  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "Failed to load profile stats" });
  }
};