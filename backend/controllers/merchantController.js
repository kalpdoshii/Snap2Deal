const Coupon = require("../models/Coupon");

exports.createCoupon = async (req, res) => {
  const {
    merchantId,
    title,
    type,
    minBillAmount,
    discountValue,
    expiryDate
  } = req.body;

  const coupon = await Coupon.create({
    merchantId,
    title,
    type,
    minBillAmount,
    discountValue,
    expiryDate
  });

  res.json({
    message: "Coupon created successfully",
    coupon
  });
};
