import express from "express";
import {
  addUserLocation,
  addRestaurantLocation,
} from "../controllers/locationController.js";

const router = express.Router();

router.post("/user-location", addUserLocation);
router.put("/restaurant-location", addRestaurantLocation);

export default router;
