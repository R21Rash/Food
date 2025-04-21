// middlewares/cloudinaryUpload.js
import { v2 as cloudinary } from "cloudinary";
import multer from "multer";
import { CloudinaryStorage } from "multer-storage-cloudinary";

// ✅ Cloudinary configuration
cloudinary.config({
  cloud_name: "dsmxio5lg", // your cloud name
  api_key: "587864288277573", // your API key
  api_secret: "f4PiBtzeGZG8bqUN0Dn3R50Recs", // your API secret
});

// ✅ Create Cloudinary Storage Engine for Multer
const storage = new CloudinaryStorage({
  cloudinary: cloudinary,
  params: {
    folder: "restaurant_products", // Folder in Cloudinary
    allowed_formats: ["jpg", "jpeg", "png", "webp"],
    transformation: [{ width: 800, height: 800, crop: "limit" }],
  },
});

// ✅ Multer Upload Middleware
const upload = multer({ storage });

export default upload;
