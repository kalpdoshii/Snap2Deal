const express = require("express");
const router = express.Router();

const { getCouponsByMerchant } = require("../controllers/couponController");
const checkSubscription = require("../middlewares/checkSubscription");
const authMiddleware = require("../middlewares/authMiddleware");



router.get(
  "/merchant/:merchantId",
  authMiddleware,
  getCouponsByMerchant
);
module.exports = router;