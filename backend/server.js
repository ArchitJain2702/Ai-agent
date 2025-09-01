// server.js
import express from "express";
import dotenv from "dotenv";
import cors from "cors";
import mongoose from "mongoose";
import authRoutes from "./routes/auth.js";
import youtubeRoutes from "./routes/youtube.js";
import { sendOTPEmail } from "./utils/email.js";

dotenv.config();

const app = express();
app.use(cors());
app.use(express.json());

// Mongo connection
mongoose
  .connect(process.env.MONGO_URI)
  .then(() => console.log("MongoDB connected ✅"))
  .catch((err) => console.error("Mongo error:", err));

// Routes
app.use("/api/auth", authRoutes);
app.use("/api", youtubeRoutes);

// Health check
app.get("/", (_req, res) => res.send("Backend is running 🚀"));

app.post("/test-email", async (req, res) => {
  try {
    const testEmail = "jain0archana@gmail.com"; // replace with your real email
    const otp = Math.floor(100000 + Math.random() * 900000); // 6 digit OTP

    await sendOTPEmail(testEmail, otp);

    res.json({ success: true, message: `Email sent to ${testEmail}` });
  } catch (err) {
    console.error("Email error:", err);
    res.status(500).json({ success: false, error: err.message });
  }
});

const PORT = process.env.PORT || 4000;
app.listen(PORT, "0.0.0.0", () => {
  console.log(`🚀 Server running at http://0.0.0.0:${PORT}`);
});

