import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:mobile_app_flutter/views/components/location_provider.dart';
import 'package:mobile_app_flutter/views/payment/payment_succ.dart';
import 'package:payhere_mobilesdk_flutter/payhere_mobilesdk_flutter.dart';
import 'package:provider/provider.dart';

class CartModal {
  static void showCartModal(
    BuildContext context,
    List<Map<String, dynamic>> cartItems,
    Function setStateCallback,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            final locationProvider = Provider.of<LocationProvider>(
              context,
              listen: true,
            );

            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              decoration: const BoxDecoration(
                color: Color(0xFF1C1C2B),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25),
                ),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 15,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Cart",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(Icons.close, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child:
                        cartItems.isEmpty
                            ? const Center(
                              child: Text(
                                "Your cart is empty 🛒",
                                style: TextStyle(color: Colors.white70),
                              ),
                            )
                            : ListView.builder(
                              itemCount: cartItems.length,
                              itemBuilder: (context, index) {
                                final item = cartItems[index];
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 10,
                                  ),
                                  child: Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.asset(
                                          item["image"],
                                          width: 60,
                                          height: 60,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      const SizedBox(width: 15),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item["title"],
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                            Text(
                                              "\$${item["price"]}",
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          IconButton(
                                            icon: const Icon(
                                              Icons.remove_circle_outline,
                                              color: Colors.white,
                                            ),
                                            onPressed: () {
                                              setStateCallback(() {
                                                if (item["quantity"] > 1) {
                                                  item["quantity"]--;
                                                } else {
                                                  cartItems.removeAt(index);
                                                }
                                              });
                                            },
                                          ),
                                          Text(
                                            "${item["quantity"]}",
                                            style: const TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.add_circle_outline,
                                              color: Colors.white,
                                            ),
                                            onPressed: () {
                                              setStateCallback(() {
                                                item["quantity"]++;
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "TOTAL:",
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        Text(
                          "LKR ${_calculateTotalPrice(cartItems).toStringAsFixed(2)}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "DELIVERY ADDRESS",
                              style: TextStyle(color: Colors.white70),
                            ),
                            GestureDetector(
                              onTap: () => _openLocationPicker(context),
                              child: const Text(
                                "EDIT",
                                style: TextStyle(color: Colors.orange),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white10,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            locationProvider.currentAddress,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 20,
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            cartItems.isEmpty
                                ? Colors.orange[200]
                                : Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed:
                          cartItems.isEmpty
                              ? null // Disables the button
                              : () {
                                final payment = {
                                  "sandbox": true,
                                  "merchant_id": "1229906",
                                  "notify_url":
                                      "https://sandbox.payhere.lk/notify",
                                  "order_id": "TESTORDER001",
                                  "items": "Test Item",
                                  "amount": "1000.00",
                                  "currency": "LKR",
                                  "first_name": "Test",
                                  "last_name": "User",
                                  "email": "test@user.com",
                                  "phone": "0771234567",
                                  "address": "Test Address",
                                  "city": "Colombo",
                                  "country": "Sri Lanka",
                                };
                                PayHere.startPayment(
                                  payment,
                                  (paymentId) {
                                    print("✅ Payment Success. ID: $paymentId");
                                    Navigator.pop(context); // close modal
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => PaymentSuccessScreen(),
                                      ),
                                    );
                                  },
                                  (error) {
                                    print("❌ Payment Failed: $error");
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text("Payment Failed: $error"),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  },
                                  () => print("ℹ️ Payment Dismissed"),
                                );
                              },

                      child: const Center(
                        child: Text(
                          "PLACE ORDER",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  static double _calculateTotalPrice(List<Map<String, dynamic>> cartItems) {
    double total = 0;
    for (var item in cartItems) {
      total += double.parse(item["price"]) * item["quantity"];
    }
    return total;
  }

  static void _openLocationPicker(BuildContext context) async {
    final locationProvider = Provider.of<LocationProvider>(
      context,
      listen: false,
    );
    LatLng selectedLocation = locationProvider.currentLocation;

    try {
      Position? position = await Geolocator.getLastKnownPosition();
      if (position == null) {
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best,
        );
      }
      selectedLocation = LatLng(position.latitude, position.longitude);
    } catch (e) {
      debugPrint("Location fetch failed: $e");
    }

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.85,
          child: FlutterMap(
            mapController: MapController(),
            options: MapOptions(
              initialCenter: selectedLocation,
              initialZoom: 14.0,
              onTap: (tapPosition, position) async {
                String address = await locationProvider.getAddressFromLatLng(
                  position.latitude,
                  position.longitude,
                );
                locationProvider.updateLocation(position, address);
              },
            ),
            children: [
              TileLayer(
                urlTemplate:
                    "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                subdomains: ['a', 'b', 'c'],
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: selectedLocation,
                    width: 80.0,
                    height: 80.0,
                    child: const Icon(
                      Icons.location_pin,
                      size: 40.0,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
