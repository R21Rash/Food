import mongoose from "mongoose";

const locationSchema = new mongoose.Schema({
  orderId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "Order", // Assuming there's an Order model
    required: true,
    unique: true,
  },
  userLocation: {
    lat: Number,
    lng: Number,
    address: String,
    addedAt: {
      type: Date,
      default: Date.now,
    },
  },
  restaurantLocation: {
    lat: Number,
    lng: Number,
    address: String,
    addedAt: Date,
  },
  // future: deliveryLocation
});

const Location = mongoose.model("Location", locationSchema);
export default Location;
