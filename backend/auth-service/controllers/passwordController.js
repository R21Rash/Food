import twilio from 'twilio';
import User from '../models/User.js'; // Import User model
import crypto from 'crypto';

// Twilio credentials
const accountSid = 'ACa1abbdef5a5daf83bd8639110715278f';
const authToken = 'e0acc334cf523417cf30ddd5df203e72';
const fromPhoneNumber = '+19787056998'; // Twilio phone number

const client = new twilio(accountSid, authToken);

// In-memory OTP storage (keyed by phone number)
const otpStore = {};

// Function to generate OTP
const generateOtp = () => {
  return Math.floor(1000 + Math.random() * 9000).toString();
};

// API to verify if the phone number exists in the database
const verifyPhone = async (req, res) => {
  const { phone } = req.body;

  try {
    const user = await User.findOne({ phone });

    if (!user) {
      return res.status(404).json({ message: 'Phone number not found' });
    }

    res.status(200).json({ message: 'Phone number found' });
  } catch (err) {
    console.error('Error verifying phone:', err);
    res.status(500).json({ message: 'Server error' });
  }
};

// API to send OTP to the phone number
const sendOtp = async (req, res) => {
  const { phone } = req.body;

  try {
    const user = await User.findOne({ phone });

    if (!user) {
      return res.status(404).json({ message: 'Phone number not found' });
    }

    const otp = generateOtp();
    const otpExpiry = Date.now() + 10 * 60 * 1000; // OTP expires in 10 minutes

    // Store OTP and expiry time in memory
    otpStore[phone] = { otp, otpExpiry };

    // Send OTP via Twilio
    await client.messages.create({
      body: `Your OTP for password reset is ${otp}`,
      from: fromPhoneNumber,
      to: phone,
    });

    console.log('OTP sent to', phone);
    res.status(200).json({ message: 'OTP sent successfully' });
  } catch (err) {
    console.error('Error sending OTP:', err);
    res.status(500).json({ message: 'Server error' });
  }
};

// API to verify if the OTP is correct
const verifyUsernamePhone = async (req, res) => {
  const { phone, otp } = req.body;

  try {
    const user = await User.findOne({ phone });

    if (!user) {
      return res.status(404).json({ message: 'Phone number not found' });
    }

    const storedOtpData = otpStore[phone];

    if (!storedOtpData) {
      return res.status(400).json({ message: 'OTP not sent or expired' });
    }

    const { otp: storedOtp, otpExpiry } = storedOtpData;

    if (storedOtp !== otp) {
      return res.status(400).json({ message: 'Invalid OTP' });
    }

    if (Date.now() > otpExpiry) {
      delete otpStore[phone]; // Clean up expired OTP
      return res.status(400).json({ message: 'OTP has expired' });
    }

    res.status(200).json({ message: 'OTP verified successfully' });
  } catch (err) {
    console.error('Error verifying OTP:', err);
    res.status(500).json({ message: 'Server error' });
  }
};

// API to reset the password
const resetPassword = async (req, res) => {
  const { phone, newPassword } = req.body;

  try {
    const user = await User.findOne({ phone });

    if (!user) {
      return res.status(404).json({ message: 'Phone number not found' });
    }

    // Hash the new password before saving (optional, depending on your hashing strategy)
    user.password = newPassword; // You may want to hash this password before saving
    await user.save();

    res.status(200).json({ message: 'Password reset successfully' });
  } catch (err) {
    console.error('Error resetting password:', err);
    res.status(500).json({ message: 'Server error' });
  }
};

export {
  verifyPhone,
  sendOtp,
  verifyUsernamePhone,
  resetPassword,
};
