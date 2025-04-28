import mongoose from "mongoose";

const userSchema = new mongoose.Schema({
  role: {
    type: String,
    enum: ["Customer", "Restaurant", "Delivery"],
    required: true,
  },
  fullName: {
    type: String,
  },
  restaurantName: {
    type: String,
  },
  email: {
    type: String,
    required: true,
    unique: true,
    lowercase: true,
  },
  phone: {
    type: String,
    required: true,
  },
  password: {
    type: String,
    required: true,
  },
  status: {
    type: String,
    enum: ["active", "inactive"],
    default: "active",
  },
  otp: {
    type: String,
  },
  otpExpire: {
    type: Date,
  },
});


const User = mongoose.model("User", userSchema);
export default User;
