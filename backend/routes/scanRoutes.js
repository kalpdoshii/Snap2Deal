const express = require("express");
const router = express.Router();

const { scanCoupon } = require("../controllers/scanController");

router.post("/scan", scanCoupon);

module.exports = router;
