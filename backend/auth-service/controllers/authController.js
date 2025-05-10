import bcrypt from "bcryptjs";
import User from "../models/User.js";

/**
 * Register a new user
 */
export const registerUser = async (req, res) => {
  try {
    const { role, fullName, restaurantName, email, password, phone } = req.body;

    // Check if the user already exists based on email
    const existingUser = await User.findOne({ email });
    if (existingUser) {
      return res.status(400).json({ message: "User already exists" });
    }

    // Hash the password for security
    const hashedPassword = await bcrypt.hash(password, 10);

    // Create a new user object
    const user = new User({
      role,
      fullName: role !== "Restaurant" ? fullName : undefined,
      restaurantName: role === "Restaurant" ? restaurantName : undefined,
      email,
      phone,
      password: hashedPassword,
      status: "active", // New accounts are active by default
    });

    // Save the user to the database
    await user.save();

    res.status(201).json({
      message: "User registered successfully",
      user,
    });
  } catch (error) {
    console.error("Registration Error:", error);
    res.status(500).json({ message: "Server Error", error });
  }
};

/**
 * Login user with email and password
 */
export const loginUser = async (req, res) => {
  try {
    const { email, password } = req.body;

    // Find user by email
    const user = await User.findOne({ email });
    if (!user)
      return res.status(400).json({ message: "Invalid email or password" });

    // Check if account is active
    if (user.status !== "active")
      return res.status(403).json({
        message: "Account is inactive. Please contact support.",
      });

    // Compare provided password with stored hashed password
    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch)
      return res.status(400).json({ message: "Invalid email or password" });

    // Prepare the user data to send (without sensitive fields)
    const userData = {
      _id: user._id,
      email: user.email,
      fullName: user.fullName,
      role: user.role,
      restaurantName: user.restaurantName,
      status: user.status,
      phone: user.phone,
    };

    res.status(200).json({ message: "Login successful", user: userData });
  } catch (error) {
    console.error("Login Error:", error);
    res.status(500).json({ message: "Server error", error });
  }
};

/**
 * Deactivate (soft delete) a user account
 */
export const deactivateUser = async (req, res) => {
  try {
    const { email } = req.body;

    // Validate that email is provided
    if (!email) {
      return res.status(400).json({ message: "Email is required" });
    }

    // Find the user by email
    const user = await User.findOne({ email });
    if (!user) return res.status(404).json({ message: "User not found" });

    // Update user's status to inactive
    user.status = "inactive";
    await user.save();

    res.status(200).json({ message: "Account deactivated successfully" });
  } catch (error) {
    console.error("Deactivate User Error:", error);
    res.status(500).json({ message: "Server error", error });
  }
};

/**
 * Update user profile (name, email, phone)
 */
export const updateProfile = async (req, res) => {
  try {
    const { userId, newName, newEmail, newPhone } = req.body;

    // Validate that userId is provided
    if (!userId) {
      return res.status(400).json({ message: "User ID is required" });
    }

    // Find user by ID
    const user = await User.findById(userId);
    if (!user) return res.status(404).json({ message: "User not found" });

    // Update fields if new values are provided
    user.fullName = newName || user.fullName;
    user.email = newEmail || user.email;
    user.phone = newPhone || user.phone;

    // Save updated user
    await user.save();

    res.status(200).json({ message: "Profile updated successfully", user });
  } catch (error) {
    console.error("Update Profile Error:", error);
    res.status(500).json({ message: "Server error", error });
  }
};
