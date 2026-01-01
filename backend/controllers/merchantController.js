const Coupon = require("../models/Coupon");
const Merchant = require("../models/Merchant");

exports.getApprovedMerchants = async (req, res) => {
  try {
    const merchants = await Merchant.find({
      isApproved: true,
      isActive: true
    }).select("name category address");

    res.json(merchants);
  } catch (err) {
    res.status(500).json({ message: "Failed to fetch merchants" });
  }
};

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
