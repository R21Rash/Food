const cloudinary = require("cloudinary").v2;
const { CloudinaryStorage } = require("multer-storage-cloudinary");

cloudinary.config({
  cloud_name: "dsmxio5lg",
  api_key: "587864288277573",
  api_secret: "f4PiBtzeGZG8bqUN0Dn3R50Recs",
});

const storage = new CloudinaryStorage({
  cloudinary,
  params: {
    folder: "restaurant_products",
    allowed_formats: ["jpg", "jpeg", "png"],
  },
});

module.exports = { cloudinary, storage };
