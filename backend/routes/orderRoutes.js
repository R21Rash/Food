import express from "express";
import {
  createOrder,
  fetchOrdersByRestaurant,
  updateOrderStatus,
  fetchPendingDeliveries,
  fetchOrdersByUserId,
} from "../controllers/orderController.js";

const router = express.Router();

router.post("/create", createOrder);
router.get("/by-restaurant/:restaurantName", fetchOrdersByRestaurant);
router.put("/update/:id", updateOrderStatus);
router.get("/pending-delivery", fetchPendingDeliveries);
router.get("/by-user/:userId", fetchOrdersByUserId);
export default router;
