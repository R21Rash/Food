import express from "express";
import mongoose from "mongoose";
import dotenv from "dotenv";
import cors from "cors";
import locationRoutes from "./routes/locationRoutes.js";

dotenv.config();
const app = express();
const PORT = process.env.PORT || 5002;

app.use(cors());
app.use(express.json());

app.use("/api/location", locationRoutes);

mongoose
  .connect(process.env.MONGO_URL)
  .then(() => {
    console.log(" Location Service connected to MongoDB");
    app.listen(PORT, () =>
      console.log(` Location Service running on port ${PORT}`)
    );
  })
  .catch((err) => {
    console.error("MongoDB error:", err.message);
  });
