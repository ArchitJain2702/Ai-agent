// routes/auth.js
import express from "express";
import jwt from "jsonwebtoken";
import Otp from "../models/otp.js";
import User from "../models/user.js";
import { sendOTPEmail } from "../utils/email.js";
import { generateOTP, twoMinutesFromNow } from "../utils/otp.js";

const router = express.Router();

// JWT helpers
const makeSignupToken = (email) =>
  jwt.sign({ email, flow: "signup" }, process.env.JWT_SECRET, { expiresIn: "10m" });

const makeAccessToken = (user) =>
  jwt.sign({ id: user._id }, process.env.JWT_SECRET, { expiresIn: "1d" });

// ===== 1) SIGNUP: request OTP =====
router.post("/signup/request-otp", async (req, res) => {
  try {
    const rawEmail = req.body.email;
    if (!rawEmail) return res.status(400).json({ message: "Email is required" });
    const email = rawEmail.toLowerCase().trim();

    const exists = await User.findOne({ email });
    if (exists) return res.status(400).json({ message: "User already exists. Cannot sign up." });

    const code = generateOTP();
    await Otp.findOneAndUpdate(
      { email, purpose: "signup" },
      { code, purpose: "signup", expiresAt: twoMinutesFromNow() },
      { upsert: true, new: true, setDefaultsOnInsert: true }
    );

    await sendOTPEmail(email, code);
    return res.json({ message: "OTP sent to email for signup" });
  } catch (err) {
    console.error("signup/request-otp", err);
    return res.status(500).json({ message: "Failed to send signup OTP" });
  }
});

// ===== 2) SIGNUP: verify OTP =====
router.post("/signup/verify-otp", async (req, res) => {
  try {
    const rawEmail = req.body.email;
    const { otp } = req.body;
    if (!rawEmail || !otp) return res.status(400).json({ message: "Email and OTP are required" });
    const email = rawEmail.toLowerCase().trim();

    const exists = await User.findOne({ email });
    if (exists) return res.status(400).json({ message: "User already exists. Cannot sign up." });

    const doc = await Otp.findOne({ email, purpose: "signup", code: otp });
    if (!doc) return res.status(400).json({ message: "Invalid OTP" });
    if (doc.expiresAt < new Date()) return res.status(400).json({ message: "OTP expired" });

    await Otp.deleteOne({ _id: doc._id });

    const signupToken = makeSignupToken(email);
    return res.json({ message: "OTP verified. Continue signup.", signupToken });
  } catch (err) {
    console.error("signup/verify-otp", err);
    return res.status(500).json({ message: "Failed to verify signup OTP" });
  }
});

// ===== 3) SIGNUP: complete profile =====
router.post("/signup/complete", async (req, res) => {
  try {
    const { signupToken, name, gender, occupation, extraDetails, phoneNumber } = req.body;
    if (!signupToken) return res.status(400).json({ message: "signupToken is required" });
    if (!name) return res.status(400).json({ message: "Name is required" });

    let payload;
    try {
      payload = jwt.verify(signupToken, process.env.JWT_SECRET);
    } catch {
      return res.status(400).json({ message: "Invalid or expired signup token" });
    }
    if (payload.flow !== "signup" || !payload.email) {
      return res.status(400).json({ message: "Bad signup token" });
    }

    const email = payload.email.toLowerCase().trim();
    const existing = await User.findOne({ email });
    if (existing) return res.status(400).json({ message: "User already exists" });

    const user = await User.create({
      email,
      name,
      gender,
      occupation,
      extraDetails,
      phoneNumber
    });

    const accessToken = makeAccessToken(user);
    return res.json({ message: "Signup completed", user, token: accessToken });
  } catch (err) {
    console.error("signup/complete", err);
    return res.status(500).json({ message: "Failed to complete signup" });
  }
});

// ===== 4) SIGNIN: request OTP =====
router.post("/signin/request-otp", async (req, res) => {
  try {
    const rawEmail = req.body.email;
    if (!rawEmail) return res.status(400).json({ message: "Email is required" });
    const email = rawEmail.toLowerCase().trim();

    const user = await User.findOne({ email });
    if (!user) return res.status(404).json({ message: "Email does not exist. Please sign up." });

    const code = generateOTP();
    await Otp.findOneAndUpdate(
      { email, purpose: "signin" },
      { code, purpose: "signin", expiresAt: twoMinutesFromNow() },
      { upsert: true, new: true, setDefaultsOnInsert: true }
    );

    await sendOTPEmail(email, code);
    return res.json({ message: "OTP sent to email for signin" });
  } catch (err) {
    console.error("signin/request-otp", err);
    return res.status(500).json({ message: "Failed to send signin OTP" });
  }
});

// ===== 5) SIGNIN: verify OTP =====
router.post("/signin/verify-otp", async (req, res) => {
  try {
    const rawEmail = req.body.email;
    const { otp } = req.body;
    if (!rawEmail || !otp) return res.status(400).json({ message: "Email and OTP are required" });
    const email = rawEmail.toLowerCase().trim();

    const user = await User.findOne({ email });
    if (!user) return res.status(404).json({ message: "Email does not exist. Please sign up." });

    const doc = await Otp.findOne({ email, purpose: "signin", code: otp });
    if (!doc) return res.status(400).json({ message: "Invalid OTP" });
    if (doc.expiresAt < new Date()) return res.status(400).json({ message: "OTP expired" });

    await Otp.deleteOne({ _id: doc._id });

    const token = makeAccessToken(user);
    return res.json({ message: "Signin successful", user, token });
  } catch (err) {
    console.error("signin/verify-otp", err);
    return res.status(500).json({ message: "Failed to verify signin OTP" });
  }
});

export default router;
