// utils/otp.js
import crypto from "crypto";

export function generateOTP() {
  return crypto.randomInt(100000, 999999).toString(); // 6 digits
}

export function twoMinutesFromNow() {
  return new Date(Date.now() + 2 * 60 * 1000);
}
