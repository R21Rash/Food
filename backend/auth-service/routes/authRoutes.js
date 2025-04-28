import express from "express";
import {
  registerUser,
  loginUser,
  deactivateUser,
  updateProfile,
  sendOtp,
  verifyOtp,
  resetPassword,
} from "../controllers/authController.js";

const router = express.Router();

router.post("/signup", registerUser);
router.post("/login", loginUser);
router.post("/deactivate", deactivateUser);
router.put("/updateProfile", updateProfile);

router.post("/send-otp", sendOtp);

// Route to verify OTP
router.post("/verify-otp", verifyOtp);

// Route to reset password
router.post("/reset-password", resetPassword);

export default router;

// http://192.168.8.218:5001/api/auth
