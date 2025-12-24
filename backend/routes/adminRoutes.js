const express = require("express");
const router = express.Router();

const { approveMerchant } = require("../controllers/adminController");

router.post("/approve-merchant", approveMerchant);

module.exports = router;
