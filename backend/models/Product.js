import mongoose from "mongoose";

const productSchema = new mongoose.Schema({
  name: { type: String, required: true },
  price: { type: Number, required: true },
  size: { type: String, required: true },
  description: String,
  deliveryType: { type: String, enum: ["Free", "Paid"], required: true },
  status: {
    type: String,
    enum: ["Available", "Not Available"],
    default: "Available",
  },
  time: String,
  restaurantName: { type: String, required: true },
  images: {
    type: [String],
    validate: {
      validator: function (val) {
        return val.length >= 1 && val.length <= 3;
      },
      message: "You must upload at least 1 and at most 3 images.",
    },
  },
});

const Product = mongoose.model("Product", productSchema);

export default Product;
