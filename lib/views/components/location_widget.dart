import 'package:flutter/material.dart';
import 'package:mobile_app_flutter/views/components/location_provider.dart';
import 'package:provider/provider.dart';
import 'package:latlong2/latlong.dart';

class LocationWidget extends StatefulWidget {
  const LocationWidget({Key? key}) : super(key: key);

  @override
  State<LocationWidget> createState() => _LocationWidgetState();
}

class _LocationWidgetState extends State<LocationWidget> {
  bool isEditing = false;
  final _manualLocationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () =>
          Provider.of<LocationProvider>(
            context,
            listen: false,
          ).fetchCurrentLocation(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locationProvider = Provider.of<LocationProvider>(context);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Your Location:",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 10),
          isEditing
              ? Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _manualLocationController,
                      decoration: const InputDecoration(
                        hintText: "Enter location manually...",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      final manualAddress = _manualLocationController.text;
                      if (manualAddress.isNotEmpty) {
                        locationProvider.updateLocation(
                          locationProvider.currentLocation,
                          manualAddress,
                        );
                        setState(() => isEditing = false);
                      }
                    },
                    child: const Text("Save"),
                  ),
                ],
              )
              : Row(
                children: [
                  Expanded(
                    child: Text(
                      locationProvider.currentAddress,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
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
