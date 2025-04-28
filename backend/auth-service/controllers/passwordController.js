// import User from "../models/User.js";
// import nodemailer from "nodemailer";
// import crypto from "crypto"; // to generate a 4-digit OTP
// import bcrypt from "bcryptjs";

// // Function to send OTP to the user
// export const sendOtp = async (req, res) => {
//   const { email } = req.body;

//   try {
//     const user = await User.findOne({ email });
//     if (!user) {
//       return res.status(404).json({ message: "User not found!" });
//     }

//     const otp = Math.floor(1000 + Math.random() * 9000);
//     user.otp = otp;
//     user.otpExpire = Date.now() + 10 * 60 * 1000;
//     await user.save();

//     // Log the email you're sending to (for debugging)
//     console.log(`[SEND OTP] Sending OTP ${otp} to ${email}`);

//     const transporter = nodemailer.createTransport({
//       service: "gmail",
//       auth: {
//         user: process.env.EMAIL_USER,
//         pass: process.env.EMAIL_PASS,
//       },
//     });

//     const mailOptions = {
//       from: process.env.EMAIL_USER,
//       to: email,
//       subject: "Password Reset OTP",
//       text: `Your OTP for password reset is ${otp}. It will expire in 10 minutes.`,
//     };

//     transporter.sendMail(mailOptions, (err, info) => {
//       if (err) {
//         console.error("[EMAIL ERROR]", err); // log the real error
//         return res
//           .status(500)
//           .json({ message: "Error sending email", error: err.toString() });
//       }
//       console.log("[EMAIL SENT SUCCESSFULLY]", info.response);
//       res.status(200).json({ message: "OTP sent to your email!" });
//     });
//   } catch (error) {
//     console.error(error);
//     res.status(500).json({ message: "Something went wrong!" });
//   }
// };

// // Function to verify the OTP
// export const verifyOtp = async (req, res) => {
//   const { email, otp } = req.body;

//   try {
//     // Check if the user exists
//     const user = await User.findOne({ email });
//     if (!user) {
//       return res.status(404).json({ message: "User not found!" });
//     }

//     // Check if OTP is valid and has not expired
//     if (user.otp !== otp) {
//       return res.status(400).json({ message: "Invalid OTP!" });
//     }

//     if (user.otpExpire < Date.now()) {
//       return res.status(400).json({ message: "OTP has expired!" });
//     }

//     res.status(200).json({ message: "OTP verified successfully!" });
//   } catch (error) {
//     console.error(error);
//     res.status(500).json({ message: "Something went wrong!" });
//   }
// };

// // Function to reset the password
// export const resetPassword = async (req, res) => {
//   const { email, newPassword } = req.body;

//   try {
//     const user = await User.findOne({ email });
//     if (!user) {
//       return res.status(404).json({ message: "User not found!" });
//     }

//     // Hash the new password
//     const hashedPassword = await bcrypt.hash(newPassword, 12);
//     user.password = hashedPassword;
//     await user.save();

//     res.status(200).json({ message: "Password reset successfully!" });
//   } catch (error) {
//     console.error(error);
//     res.status(500).json({ message: "Something went wrong!" });
//   }
// };
