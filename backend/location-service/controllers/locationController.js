import Location from "../models/locationModel.js";

// Add user location when placing the order
export const addUserLocation = async (req, res) => {
  try {
    const { orderId, lat, lng, address } = req.body;
    const location = await Location.create({
      orderId,
      userLocation: { lat, lng, address },
    });
    res.status(201).json(location);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

// Update restaurant location later
export const addRestaurantLocation = async (req, res) => {
  try {
    const { orderId, lat, lng, address } = req.body;
    const location = await Location.findOneAndUpdate(
      { orderId },
      {
        restaurantLocation: {
          lat,
          lng,
          address,
          addedAt: new Date(),
        },
      },
      { new: true }
    );
    if (!location) return res.status(404).json({ message: "Order not found" });
    res.json(location);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};
