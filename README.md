# 📱 FoodApp - Restaurant, Order, and Delivery Management Mobile App

This is a **Flutter-based mobile application** that enables restaurant owners to manage their menus and orders, customers to place and track orders, and delivery personnel to manage deliveries — all in real-time.

The backend services are containerized and orchestrated using **Docker** and **Kubernetes**.

---

## 🚀 Features

### 🏪 Restaurant Management (Restaurant Role)
- Add, update, and delete menu items.
- Set and manage restaurant availability (Open/Closed).

### 🛒 Order Management (Customer Role)
- Browse menu items and place orders.
- Modify orders before confirmation.
- Track order status in real-time (Pending, Confirmed, In Progress, Delivered).

### 🚚 Delivery Management (Delivery Role)
- Automatic assignment of delivery drivers based on location and availability.
- Real-time tracking of delivery progress for customers.

### 💳 Payment Integration
- Integrated with popular Sri Lankan payment gateway:
  - PayHere
 
### 📢 Notifications
- Customers receive email confirmations for order placement and updates.
- Delivery drivers receive real-time notifications about assigned orders.
- Email for resetting password

---

## 🛠️ Technologies Used
- **Mobile App**: Flutter (Dart)
- **Backend**: Node.js
- **Database**: MongoDB
- **Containerization**: Docker
- **Orchestration**: Kubernetes
- **Geolocation Services**: Flutter Maps API
- **Payment Gateways**: PayHere

---

## 📦 Project Setup

This project consists of two parts:
- **Frontend (Mobile App)**: Developed in Flutter.
- **Backend Services**: Deployed using Docker and Kubernetes.

---

## 🛠 How to Run the Project

### 1. Run the Backend Services

> **Important:** Kubernetes must be enabled in Docker Desktop.

- Start Docker Desktop and ensure Kubernetes is enabled.
- Open a terminal and navigate to the backend directory:

```bash
cd backend
```

- Verify Kubernetes context is set to Docker Desktop:

```bash
kubectl config current-context
```

Expected Output:
```
docker-desktop
```

- Check that backend pods are running:

```bash
kubectl get pods -n foodapp
```

Make sure all pods show a `Running` status.

---

### 2. Run the Mobile App (Flutter)

- Open the Flutter project in your preferred IDE (VS Code / Android Studio).
- Get Flutter packages:

```bash
flutter pub get
```

- Run the app on an emulator or connected device:

```bash
flutter run
```

---

## 📚 Additional Resources for Flutter Beginners
If you are new to Flutter, here are some helpful resources:
- [🌟 Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [📚 Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)
- [📖 Flutter Documentation](https://docs.flutter.dev/)

