import mongoose from "mongoose";

const orderSchema = new mongoose.Schema({
  userId: String,
  username: String,
  orderId: String,
  email: String,
  orderStatus: {
    type: String,
    default: "Order Received",
    enum: ["Order Received", "Preparing", "Picked for Delivery", "Delivered"],
  },
  items: [
    {
      title: String,
      price: String,
      quantity: Number,
      image: String,
      size: String,
      restaurantName: String,
    },
  ],
  totalAmount: String,
  deliveryLocation: {
    lat: Number,
    lng: Number,
    address: String,
  },
  createdAt: {
    type: Date,
    default: Date.now,
  },
  isCompleted: {
    type: Boolean,
    default: false,
  },
});

const Order = mongoose.model("Order", orderSchema);
export default Order;
