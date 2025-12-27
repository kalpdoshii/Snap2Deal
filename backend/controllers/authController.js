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
  console.log("VERIFY OTP BODY:", req.body);
  const { phone, otp, name, email } = req.body;

  // ✅ Basic validation
  if (!phone || !otp || !name) {
    return res
      .status(400)
      .json({ message: "Phone, OTP and Name are required" });
  }

  if (otp !== TEMP_OTP) {
    return res.status(401).json({ message: "Invalid OTP" });
  }

  let user = await User.findOne({ phone });

  if (!user) {
    // 🆕 New user
    user = await User.create({
      phone,
      name,
      email: email || null,
      isVerified: true,
    });
  } else {
    // 🔁 Existing user
    user.isVerified = true;

    // Update only if missing
    if (!user.name && name) {
      user.name = name;
    }

    if (!user.email && email) {
      user.email = email;
    }

    await user.save();
  }

  res.json({
    message: "OTP verified",
    user,
  });
};
