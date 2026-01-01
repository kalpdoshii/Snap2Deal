const User = require("../models/User");

module.exports = async (req, res, next) => {
  try {
    const userId = req.headers["userid"];

    if (!userId) {
      return res.status(401).json({
        message: "User ID missing",
      });
    }

    const user = await User.findById(userId);

    if (!user) {
      return res.status(401).json({
        message: "Invalid user",
      });
    }

    // Attach user to request
    req.user = user;

    next();
  } catch (error) {
    console.error("Auth middleware error:", error);
    res.status(500).json({
      message: "Authentication failed",
    });
  }
};
