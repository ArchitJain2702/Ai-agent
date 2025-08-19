// utils/email.js
import dotenv from "dotenv";
dotenv.config();

import nodemailer from "nodemailer";

export const transporter = nodemailer.createTransport({
  host: process.env.SMTP_HOST,
  port: process.env.SMTP_PORT,
  auth: {
     user: process.env.EMAIL_USER,
    pass: process.env.EMAIL_PASS,
  },
});


export async function sendOTPEmail(to, otp) {
  await transporter.sendMail({
    from: process.env.EMAIL_FROM,  // must be a verified sender in Brevo
    to,
    subject: "Your OTP Code",
    text: `Your OTP is ${otp}. It expires in 2 minutes.`,
  });
}
