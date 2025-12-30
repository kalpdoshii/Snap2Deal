const express = require("express");
const router = express.Router();
const UserCoupon = require("../models/UserCoupon");
const { updateProfile } = require("../controllers/userController"); // Import the function

router.get("/:userId/coupons", async (req, res) => {
  const coupons = await UserCoupon.find({
    userId: req.params.userId,
    status: "ACTIVE"
  }).populate("couponId");

  res.json(coupons);
});

router.put("/update-profile", updateProfile);

module.exports = router;
