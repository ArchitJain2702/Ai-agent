import crypto from "crypto";

export function generateOTP() {
  return crypto.randomInt(100000, 999999).toString(); // ✅ 6-digit OTP
}

export function otpExpired(otpDoc) {
  if (!otpDoc || !otpDoc.expiresAt) return true;
  return otpDoc.expiresAt < new Date();
}
