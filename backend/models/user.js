// models/user.js
import mongoose from "mongoose";

const userSchema = new mongoose.Schema({
  name: { type: String, required: true },
  email: { type: String, required: true, unique: true, lowercase: true, trim: true },

  phoneNumber: { type: String },
  gender: { type: String, enum: ["Male", "Female", "Other"], required: false },
  occupation: { type: String, enum: ["Student", "Teacher", "Doctor", "Other"], required: false },
  extraDetails: { type: String },

  createdAt: { type: Date, default: Date.now }
});

export default mongoose.model("User", userSchema);
