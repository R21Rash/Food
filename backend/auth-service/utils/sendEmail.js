import nodemailer from "nodemailer";
import dotenv from "dotenv";
dotenv.config();

const sendEmail = async (to, subject, text) => {
  // Create a transporter object using Gmail SMTP
  const transporter = nodemailer.createTransport({
    service: "gmail",
    auth: {
      user: process.env.EMAIL_USER,// Your Gmail address from .env
      pass: process.env.EMAIL_PASS,// Your Gmail app password from .env
    },
  });

  // Send the email with the specified details
  await transporter.sendMail({
    from: `"Password Reset" <${process.env.EMAIL_USER}>`, // Sender's name and email
    to,                                                    // Recipient
    subject,                                               // Email subject
    text,                                                  // Email plain text body
  });
};

export default sendEmail;
