module.exports = (req, res, next) => {
  const { user } = req; // attached from auth middleware

  if (!user.subscriptionExpiry) {
    return res.status(403).json({
      message: "No active subscription"
    });
  }

  if (new Date(user.subscriptionExpiry) < new Date()) {
    return res.status(403).json({
      message: "Subscription expired"
    });
  }

  next();
};
