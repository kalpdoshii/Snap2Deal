const Merchant = require("../models/Merchant");

exports.approveMerchant = async (req, res) => {
  const { merchantId } = req.body;

  const merchant = await Merchant.findById(merchantId);

  if (!merchant) {
    return res.status(404).json({ message: "Merchant not found" });
  }

  merchant.isApproved = true;
  await merchant.save();

  res.json({ message: "Merchant approved successfully" });
};
