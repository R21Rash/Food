import nodemailer from "nodemailer";
import Order from "../models/orderModel.js";

// HARD-CODED Gmail credentials 👇
const transporter = nodemailer.createTransport({
  service: "gmail",
  auth: {
    user: "saka12345apple@gmail.com", // ✅ your email
    pass: "gdsy sjgg nrju auua", // ✅ 16-char App Password from Google
  },
});

// Order confirmation email
export const sendOrderEmail = async (order) => {
  const item = order.items[0];
  const mailOptions = {
    from: `"KFood Delivery" <saka12345apple@gmail.com>`, // ✅ match above
    to: order.email || "saka12345apple@gmail.com",
    subject: "Your Order Has Been Received!",
    html: `
      <h2>Order Confirmation ✅</h2>
      <p>Dear ${order.username}, your order <strong>${order.orderId}</strong> has been received.</p>
      <p><strong>Item:</strong> ${item.title}</p>
      <p><strong>Restaurant:</strong> ${item.restaurantName}</p>
      <p><strong>Total:</strong> ${order.totalAmount}</p>
      <p>We'll notify you once it's on the way 🚀</p>
    `,
  };

  try {
    await transporter.sendMail(mailOptions);
    console.log("✅ Order email sent");
  } catch (error) {
    console.error("❌ Failed to send order email:", error.message);
  }
};

// Delivery notification email
export const sendDeliveryEmail = async (order) => {
  const item = order.items[0];
  const mailOptions = {
    from: `"KFood Delivery" <saka12345apple@gmail.com>`, // ✅ match above
    to: order.email || "saka12345apple@gmail.com",
    subject: "Your Order Has Been Delivered!",
    html: `
      <h2>Order Delivered 🎉</h2>
      <p>Dear ${order.username}, your order <strong>${order.orderId}</strong> has been delivered.</p>
      <p><strong>Item:</strong> ${item.title}</p>
      <p><strong>Restaurant:</strong> ${item.restaurantName}</p>
      <p><strong>Total:</strong> ${order.totalAmount}</p>
      <p>Thank you for choosing KFood! 🍽️</p>
    `,
  };

  try {
    await transporter.sendMail(mailOptions);
    console.log("✅ Delivery email sent");
  } catch (error) {
    console.error("❌ Failed to send delivery email:", error.message);
  }
};
export const createOrder = async (req, res) => {
  try {
    const newOrder = new Order(req.body);
    await newOrder.save();

    // ✅ Send confirmation email
    await sendOrderEmail(newOrder);

    res.status(201).json({ message: "Order created", order: newOrder });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// Fetch orders by restaurantName
export const fetchOrdersByRestaurant = async (req, res) => {
  const { restaurantName } = req.params;
  try {
    const orders = await Order.find({ "items.restaurantName": restaurantName });
    res.status(200).json(orders);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

export const updateOrderStatus = async (req, res) => {
  try {
    const orderId = req.params.id;
    const newStatus = req.body.orderStatus;

    const updatedOrder = await Order.findByIdAndUpdate(
      orderId,
      { orderStatus: newStatus },
      { new: true }
    );

    if (!updatedOrder) {
      return res.status(404).json({ message: "Order not found" });
    }

    //  Send delivery email if delivered
    if (newStatus === "Delivered") {
      await sendDeliveryEmail(updatedOrder);
    }

    res.status(200).json({
      message: "Order status updated",
      order: updatedOrder,
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

//Fetch orders that are "Preparing" (for delivery)
export const fetchPendingDeliveries = async (req, res) => {
  try {
    const orders = await Order.find({ orderStatus: "Preparing" });
    res.status(200).json(orders);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

export const fetchOrdersByUserId = async (req, res) => {
  const { userId } = req.params;
  try {
    const orders = await Order.find({
      userId,
      isCompleted: false, //  Exclude completed
    }).sort({ createdAt: -1 });
    res.status(200).json(orders);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};
// Mark an order as completed by user (frontend acknowledgment)
export const markOrderAsCompletedByUser = async (req, res) => {
  const { id } = req.params;

  try {
    const updatedOrder = await Order.findByIdAndUpdate(
      id,
      { isCompleted: true },
      { new: true }
    );

    if (!updatedOrder) {
      return res.status(404).json({ message: "Order not found" });
    }

    res
      .status(200)
      .json({ message: "Order marked as completed", order: updatedOrder });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// ✅ Update order by user (only size or delivery location allowed)
export const updateOrderByUser = async (req, res) => {
  try {
    const orderId = req.params.id;
    const { items, deliveryLocation } = req.body;

    const order = await Order.findById(orderId);
    if (!order) return res.status(404).json({ message: "Order not found" });

    if (order.orderStatus !== "Order Received") {
      return res.status(400).json({ message: "Order cannot be edited" });
    }

    if (items) order.items = items;
    if (deliveryLocation) order.deliveryLocation = deliveryLocation;

    await order.save();
    res.status(200).json({ message: "Order updated", order });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

// ❌ Cancel order by user
export const cancelOrderByUser = async (req, res) => {
  try {
    const orderId = req.params.id;
    const order = await Order.findById(orderId);
    if (!order) return res.status(404).json({ message: "Order not found" });

    if (order.orderStatus !== "Order Received") {
      return res.status(400).json({ message: "Cannot cancel processed order" });
    }

    await order.deleteOne();
    res.status(200).json({ message: "Order canceled" });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};
