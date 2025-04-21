import express from "express";
import { registerUser, loginUser , deactivateUser , updateProfile } from "../controllers/authController.js";

const router = express.Router();

router.post("/signup", registerUser);
router.post("/login", loginUser);
router.post("/deactivate", deactivateUser);
router.put("/updateProfile", updateProfile);

export default router;


// http://192.168.8.218:5001/api/auth