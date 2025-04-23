import express from 'express';
import { verifyPhone, sendOtp, verifyUsernamePhone, resetPassword } from '../controllers/passwordController.js';

const router = express.Router();

// Route to verify phone number
router.post('/verify-phone', verifyPhone);

// Route to send OTP
router.post('/send-otp', sendOtp);

// Route to verify username and phone for OTP
router.post('/verify-username-phone', verifyUsernamePhone);

// Route to reset password
router.post('/reset-password', resetPassword);

export default router;
