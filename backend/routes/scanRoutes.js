const express = require("express");
const router = express.Router();

const { scanCoupon } = require("../controllers/scanController");
const { redeemCoupon } = require("../controllers/subscriptionController");
const checkSubscription = require("../middlewares/checkSubscription");
const authMiddleware = require("../middlewares/authMiddleware");


router.post("/scan", scanCoupon);
router.post(
  "/redeem",
  authMiddleware,
  checkSubscription,
  redeemCoupon
);


module.exports = router;
