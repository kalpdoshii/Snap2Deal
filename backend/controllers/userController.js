const User = require("../models/User");

exports.updateProfile = async (req, res) => {
  console.log("UPDATE PROFILE HIT");
  console.log("BODY:", req.body);

  const { userId, name, email } = req.body;

  if (!userId || !name) {
    console.log("❌ Missing userId or name");
    return res.status(400).json({
      message: "userId and name are required",
    });
  }

  try {
    const user = await User.findById(userId);

    if (!user) {
      console.log("❌ User not found");
      return res.status(404).json({ message: "User not found" });
    }

    user.name = name;
    user.email = email || null;
    await user.save();

    console.log("✅ Profile updated");

    res.status(200).json({
      message: "Profile updated",
      user,
    });
  } catch (err) {
    console.error("❌ Update profile error:", err);
    res.status(500).json({ message: "Server error" });
  }
};
