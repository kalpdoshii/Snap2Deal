const User = require("../models/User");

// Temporary OTP (for development)
const TEMP_OTP = "123456";

// Send OTP
exports.sendOtp = async (req, res) => {
  const { phone } = req.body;

  if (!phone) {
    return res.status(400).json({ message: "Phone number is required" });
  }

  // In real app → send SMS here
  console.log(`📲 OTP for ${phone} is ${TEMP_OTP}`);

  res.json({ message: "OTP sent successfully" });
};

// Verify OTP
exports.verifyOtp = async (req, res) => {
  const { phone, otp } = req.body;

  if (!phone || !otp) {
    return res.status(400).json({ message: "Phone & OTP required" });
  }

  if (otp !== TEMP_OTP) {
    return res.status(401).json({ message: "Invalid OTP" });
  }

  let user = await User.findOne({ phone });

  if (!user) {
    user = await User.create({
      phone,
      isVerified: true
    });
  } else {
    user.isVerified = true;
    await user.save();
  }

  res.json({
    message: "OTP verified",
    user
  });
};
