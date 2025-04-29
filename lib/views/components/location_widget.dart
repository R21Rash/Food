import 'package:flutter/material.dart';
import 'package:mobile_app_flutter/views/components/location_provider.dart';
import 'package:provider/provider.dart';
import 'package:latlong2/latlong.dart';

// Widget for displaying and editing user location
class LocationWidget extends StatefulWidget {
  const LocationWidget({Key? key}) : super(key: key);

  @override
  State<LocationWidget> createState() => _LocationWidgetState();
}

class _LocationWidgetState extends State<LocationWidget> {
  bool isEditing = false; // Tracks if the user is editing the location
  final _manualLocationController = TextEditingController(); // Controller for manual location input

  // Initialize the widget and fetch the current location
  @override
  void initState() {
    super.initState();
    // Fetch current location asynchronously after widget initialization
    Future.microtask(
      () => Provider.of<LocationProvider>(
        context,
        listen: false,
      ).fetchCurrentLocation(),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Access the LocationProvider for location data
    final locationProvider = Provider.of<LocationProvider>(context);

    return Padding(
      padding: const EdgeInsets.all(16.0), // Padding around the widget
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Align children to the start
        children: [
          // Location section header
          Text(
            "Your Location:",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 10), // Spacing below header
          isEditing
              ? Row(
                  children: [
                    // Text field for manual location input
                    Expanded(
                      child: TextField(
                        controller: _manualLocationController,
                        decoration: const InputDecoration(
                          hintText: "Enter location manually...",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8), // Spacing between text field and button
                    // Save button to update location
                    ElevatedButton(
                      onPressed: () {
                        final manualAddress = _manualLocationController.text;
                        if (manualAddress.isNotEmpty) {
                          // Update location with manual address
                          locationProvider.updateLocation(
                            locationProvider.currentLocation,
                            manualAddress,
                          );
                          setState(() => isEditing = false); // Exit editing mode
                        }
                      },
                      child: const Text("Save"),
                    ),
                  ],
                )
              : Row(
                  children: [
                    // Display current address
                    Expanded(
                      child: Text(
                        locationProvider.currentAddress,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                    // Edit button to enter editing mode
                    IconButton(
                      onPressed: () => setState(() => isEditing = true),
                      icon: const Icon(Icons.edit_location_alt),
                    ),
                  ],
                ),
        ],
      ),
    );
  }
}
