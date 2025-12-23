const express = require("express");
const router = express.Router();

const {
  getSubscriptions,
  subscribeUser
} = require("../controllers/subscriptionController");

router.get("/", getSubscriptions);
router.post("/subscribe", subscribeUser);

module.exports = router;
