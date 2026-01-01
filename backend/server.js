const express = require("express");
const cors = require("cors");
const authRoutes = require("./routes/authRoutes");
const subscriptionRoutes = require("./routes/subscriptionRoutes");
const userRoutes = require("./routes/userRoutes");
const scanRoutes = require("./routes/scanRoutes");
const adminRoutes = require("./routes/adminRoutes");
const merchantRoutes = require("./routes/merchantRoutes");
const couponRoutes = require("./routes/couponRoutes");
//const paymentRoutes = require("./routes/paymentRoutes");




require("dotenv").config();

const connectDB = require("./config/db");

const app = express();

// Middleware
app.use(cors());
app.use(express.json());
app.use("/api/auth", authRoutes);
app.use("/api/subscriptions", subscriptionRoutes);
app.use("/api/users", userRoutes);
app.use("/api/scan", scanRoutes);
app.use("/api/admin", adminRoutes);
app.use("/api/merchant", merchantRoutes);
app.use("/api/coupons", couponRoutes);
//app.use("/api/payment", paymentRoutes);





// Connect DB
connectDB();

// Test Route
app.get("/", (req, res) => {
  res.send("Snap2Deal Backend Running 🚀");
});

// Start Server
const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
  console.log(`✅ Server running on port ${PORT}`);
});
