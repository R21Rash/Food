import express from "express";
import mongoose from "mongoose";
import dotenv from "dotenv";
import cors from "cors";
import authRoutes from "./routes/authRoutes.js";
// import passwordRoutes from "./routes/passwordRoutes.js";

dotenv.config();

const app = express();
const PORT = process.env.PORT || 5001;

// Middleware
app.use(cors());
app.use(express.json());

// Routes
app.use("/api/auth", authRoutes);
// app.use("/api/password", passwordRoutes);

// MongoDB connection
mongoose
  .connect(process.env.MONGO_URL)
  .then(() => {
    console.log(" Auth Service connected to MongoDB");
    app.listen(PORT, () =>
      console.log(` Auth Service running on port ${PORT}`)
    );
  })
  .catch((err) => {
    console.error(" MongoDB connection error:", err.message);
  });
