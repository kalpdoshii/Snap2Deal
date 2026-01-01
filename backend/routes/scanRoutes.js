const express = require("express");
const router = express.Router();

const { scanCoupon } = require("../controllers/scanController");
const { redeemCoupon } = require("../controllers/subscriptionController");

router.post("/scan", scanCoupon);
router.post("/redeem", redeemCoupon);


module.exports = router;
