// controllers/productController.js
import Product from "../models/Product.js";
// Adjust the import path as necessary

export const addProduct = async (req, res) => {
  try {
    const {
      name,
      price,
      size,
      description,
      deliveryType,
      status,
      time,
      restaurantName,
    } = req.body;

    const images = req.files.map((file) => file.path);
    if (!images.length) {
      return res
        .status(400)
        .json({ message: "At least one image is required" });
    }

    const product = new Product({
      name,
      price,
      size,
      description,
      deliveryType,
      status,
      time,
      restaurantName,
      images,
    });

    await product.save();
    res.status(201).json(product);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

export const getAllProducts = async (req, res) => {
  const products = await Product.find().sort({ createdAt: -1 });
  res.json(products);
};

export const getProductById = async (req, res) => {
  const product = await Product.findById(req.params.id);
  if (!product) return res.status(404).json({ message: "Product not found" });
  res.json(product);
};

export const updateProduct = async (req, res) => {
  const updates = req.body;
  const product = await Product.findByIdAndUpdate(req.params.id, updates, {
    new: true,
  });
  if (!product) return res.status(404).json({ message: "Product not found" });
  res.json(product);
};

export const deleteProduct = async (req, res) => {
  const product = await Product.findByIdAndDelete(req.params.id);
  if (!product) return res.status(404).json({ message: "Product not found" });
  res.json({ message: "Product deleted" });
};

export const getProductsByRestaurantName = async (req, res) => {
  try {
    const { name } = req.params;

    const products = await Product.find({ restaurantName: name }).sort({
      createdAt: -1,
    });

    res.json(products);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};
