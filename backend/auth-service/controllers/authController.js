import bcrypt from "bcryptjs";
import User from "../models/User.js";

export const registerUser = async (req, res) => {
  try {
    const { role, fullName, restaurantName, email, password, phone } = req.body;

    const existingUser = await User.findOne({ email });
    if (existingUser) {
      return res.status(400).json({ message: "User already exists" });
    }

    const hashedPassword = await bcrypt.hash(password, 10);

    const user = new User({
      role,
      fullName: role !== "Restaurant" ? fullName : undefined,
      restaurantName: role === "Restaurant" ? restaurantName : undefined,
      email,
      phone, // <-- include phone here
      password: hashedPassword,
      status: "active",
    });

    await user.save();

    res.status(201).json({
      message: "User registered successfully",
      user,
    });
  } catch (error) {
    res.status(500).json({ message: "Server Error", error });
  }
};


export const loginUser = async (req, res) => {
  try {
    const { email, password } = req.body;

    const user = await User.findOne({ email });
    if (!user)
      return res.status(400).json({ message: "Invalid email or password" });

    if (user.status !== "active")
      return res.status(403).json({
        message: "Account is inactive. Please contact support.",
      });

    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch)
      return res.status(400).json({ message: "Invalid email or password" });

    // Extract only the required fields
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
    res.status(500).json({ message: "Server error", error });
  }
};


export const deactivateUser = async (req, res) => {
  try {
    const { email } = req.body; // Only need the email to deactivate the user

    if (!email) {
      return res.status(400).json({ message: "Email is required" });
    }

    const user = await User.findOne({ email });
    if (!user) return res.status(404).json({ message: "User not found" });

    // Update the user's status to inactive
    user.status = "inactive";
    await user.save();

    res.status(200).json({ message: "Account deactivated successfully" });
  } catch (error) {
    res.status(500).json({ message: "Server error", error });
  }
};


export const updateProfile = async (req, res) => {
  try {
    const { userId, newName, newEmail, newPhone } = req.body;

    // Check if userId is provided
    if (!userId) {
      return res.status(400).json({ message: "User ID is required" });
    }

    // Find user by _id
    const user = await User.findById(userId);
    if (!user) return res.status(404).json({ message: "User not found" });

    // Update fields if provided
    user.fullName = newName || user.fullName;
    user.email = newEmail || user.email;
    user.phone = newPhone || user.phone;

    await user.save();

    res.status(200).json({ message: "Profile updated successfully", user });
  } catch (error) {
    console.error("Update Profile Error:", error);
    res.status(500).json({ message: "Server error", error });
  }
};


