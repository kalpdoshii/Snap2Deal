const User = require("../models/User");

exports.updateProfile = async (req, res) => {
  const { userId, name, email } = req.body;

  if (!userId || !name) {
    return res
      .status(400)
      .json({ message: "UserId and name are required" });
  }

  try {
    const user = await User.findByIdAndUpdate(
      userId,
      {
        name,
        email: email || null,
      },
      { new: true }
    );

    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }

    res.json({
      message: "Profile updated successfully",
      user,
    });
  } catch (error) {
    console.error("Update profile error:", error);
    res.status(500).json({ message: "Server error" });
  }
};
