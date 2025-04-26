import express from "express";
import {
  createOrder,
  fetchOrdersByRestaurant,
  updateOrderStatus,
  fetchPendingDeliveries,
  fetchOrdersByUserId,
  markOrderAsCompletedByUser,
  updateOrderByUser,
  cancelOrderByUser,
} from "../controllers/orderController.js";

const router = express.Router();

router.post("/create", createOrder);
router.get("/by-restaurant/:restaurantName", fetchOrdersByRestaurant);
router.put("/update/:id", updateOrderStatus);
router.get("/pending-delivery", fetchPendingDeliveries);
router.get("/by-user/:userId", fetchOrdersByUserId);
router.put("/mark-complete/:id", markOrderAsCompletedByUser);
router.put("/edit/:id", updateOrderByUser);
router.delete("/cancel/:id", cancelOrderByUser);
export default router;
