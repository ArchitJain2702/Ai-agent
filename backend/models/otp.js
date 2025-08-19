// models/otp.js
import mongoose from "mongoose";

const otpSchema = new mongoose.Schema(
  {
    email: { type: String, required: true, index: true, lowercase: true, trim: true },
    code: { type: String, required: true },
    purpose: { type: String, enum: ["signup", "signin"], required: true, index: true },
    expiresAt: { type: Date, required: true }
  },
  { timestamps: true }
);

// One active OTP per (email, purpose)
otpSchema.index({ email: 1, purpose: 1 }, { unique: true });

// TTL: delete when expiresAt has passed
otpSchema.index({ expiresAt: 1 }, { expireAfterSeconds: 0 });

export default mongoose.model("Otp", otpSchema);
