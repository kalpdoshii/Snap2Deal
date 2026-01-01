const express = require("express");
const router = express.Router();

const { createCoupon } = require("../controllers/merchantController");
const Merchant = require("../models/Merchant");
const { getApprovedMerchants } = require("../controllers/merchantController");


router.post("/create-coupon", createCoupon);

router.get("/:merchantId/qr", async (req, res) => {
  const merchant = await Merchant.findById(req.params.merchantId);
  res.json({
    qrToken: merchant.qrToken
  });
});

router.get("/approved", getApprovedMerchants);


module.exports = router;
