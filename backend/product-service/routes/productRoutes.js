import express from "express";
import upload from "../middlewares/cloudinaryUpload.js";
import {
  addProduct,
  getAllProducts,
  getProductById,
  updateProduct,
  deleteProduct,
  getProductsByRestaurantName,
} from "../controllers/productController.js";

const router = express.Router();

router.post("/add", upload.array("images", 3), addProduct);
router.get("/all", getAllProducts);
router.get("/by-restaurant/:name", getProductsByRestaurantName);
router.get("/:id", getProductById);
router.put("/:id", updateProduct);
router.delete("/:id", deleteProduct);

export default router;
