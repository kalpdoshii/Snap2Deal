const express = require("express");
const router = express.Router();
const UserCoupon = require("../models/UserCoupon");

router.get("/:userId/coupons", async (req, res) => {
  const coupons = await UserCoupon.find({
    userId: req.params.userId,
    status: "ACTIVE"
  }).populate("couponId");

  res.json(coupons);
});

module.exports = router;
