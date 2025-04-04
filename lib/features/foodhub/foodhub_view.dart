import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class FoodHubPage extends StatefulWidget {
  const FoodHubPage({super.key});

  @override
  State<FoodHubPage> createState() => FoodHubState();
}

class FoodHubState extends State<FoodHubPage> {
  List<bool> isSelected = [true, false];
  LatLng? _initialPosition;
  final Location _location = Location();
  late GoogleMapController _mapController;

  @override
  void initState() {
    super.initState();
    _setInitialPosition(); // Set the initial position of the map
  }

  Future<void> _setInitialPosition() async {
    // Check if location services are enabled
    bool serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) {
        return; // Exit if location services are not enabled
      }
    }

    // Check and request location permissions
    PermissionStatus permissionGranted = await _location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return; // Exit if permissions are not granted
      }
    }

    // Get the user's current location
    final userLocation = await _location.getLocation();
    setState(() {
      _initialPosition = LatLng(
        userLocation.latitude!,
        userLocation.longitude!,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Map Container
              Container(
                height: 250,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.grey[300],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    children: [
                      // Google Map
                      GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: _initialPosition!,
                          zoom: 12.0,
                        ),
                        onMapCreated: (GoogleMapController controller) {
                          _mapController = controller;
                        },
                        markers: {
                          Marker(
                            markerId: const MarkerId('marker_1'),
                            position: _initialPosition!,
                            infoWindow: const InfoWindow(
                              title: 'Your Location',
                              snippet: 'This is your current location.',
                            ),
                          ),
                        },
                      ),

                      // Floating Action Buttons (Overlay)
                      Positioned(
                        top: 10,
                        right: 10,
                        child: Column(
                          children: [
                            FloatingActionButton(
                              mini: true,
                              onPressed: () {
                                // Center map action
                                _mapController.animateCamera(
                                  CameraUpdate.newLatLng(_initialPosition!),
                                );
                              },
                              child: const Icon(Icons.location_on),
                            ),
                            const SizedBox(height: 8),
                            FloatingActionButton(
                              mini: true,
                              onPressed: () {
                                // Toggle map view action
                              },
                              child: const Icon(Icons.layers),
                            ),
                          ],
                        ),
                      ),

                      // Distance Slider (Overlay)
                      Positioned(
                        bottom: 10,
                        left: 10,
                        right: 10,
                        child: Row(
                          children: [
                            const Text("Distance:"),
                            Expanded(
                              child: Slider(
                                value: 5,
                                min: 1,
                                max: 20,
                                divisions: 19,
                                label: "5 miles",
                                onChanged: (value) {
                                  // Handle slider change
                                },
                              ),
                            ),
                            const Text("5 miles"),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // List View Toggle
              ToggleButtons(
                isSelected: [true, false], // Initial selection state
                onPressed: (index) {
                  setState(() {
                    // Update the selection state
                    for (int i = 0; i < 2; i++) {
                      isSelected[i] = i == index;
                    }
                  });
                },
                borderRadius: BorderRadius.circular(30),
                selectedColor: Colors.white,
                fillColor: Colors.green,
                color: Colors.black,
                constraints: const BoxConstraints(minHeight: 40, minWidth: 187),
                children: const [
                  Text("Available Items"),
                  Text("My Shared Items"),
                ],
              ),
              const SizedBox(height: 16),

              // Filter Chips
              Wrap(
                spacing: 8, // Spacing between chips
                children: [
                  FilterChip(
                    label: const Text("All"),
                    selected: true,
                    onSelected: (value) {
                      setState(() {
                        // Handle filter selection
                      });
                    },
                    selectedColor: Colors.green,
                    backgroundColor: Colors.grey[200],
                    labelStyle: const TextStyle(color: Colors.white),
                  ),
                  FilterChip(
                    label: const Text("Nearby"),
                    selected: false,
                    onSelected: (value) {
                      setState(() {
                        // Handle filter selection
                      });
                    },
                    selectedColor: Colors.green,
                    backgroundColor: Colors.grey[200],
                    labelStyle: const TextStyle(color: Colors.black),
                  ),
                  FilterChip(
                    label: const Text("Free"),
                    selected: false,
                    onSelected: (value) {
                      setState(() {
                        // Handle filter selection
                      });
                    },
                    selectedColor: Colors.green,
                    backgroundColor: Colors.grey[200],
                    labelStyle: const TextStyle(color: Colors.black),
                  ),
                  FilterChip(
                    label: const Text("For Sale"),
                    selected: false,
                    onSelected: (value) {
                      setState(() {
                        // Handle filter selection
                      });
                    },
                    selectedColor: Colors.green,
                    backgroundColor: Colors.grey[200],
                    labelStyle: const TextStyle(color: Colors.black),
                  ),
                  FilterChip(
                    label: const Text("Trade"),
                    selected: false,
                    onSelected: (value) {
                      setState(() {
                        // Handle filter selection
                      });
                    },
                    selectedColor: Colors.green,
                    backgroundColor: Colors.grey[200],
                    labelStyle: const TextStyle(color: Colors.black),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Food Item Cards
              FoodItemCard(
                imageUrl: "https://randomuser.me/api/portraits/men/32.jpg",
                name: "Organic Apples (5 pcs)",
                distance: "0.5 miles away",
                availability: "Available until: 06/15",
                description:
                    "Freshly picked organic apples. Can't finish them all, happy to share!",
                price: "FREE",
              ),
              const SizedBox(height: 16),
              FoodItemCard(
                imageUrl: "https://randomuser.me/api/portraits/women/44.jpg",
                name: "Homemade Bread (Half Loaf)",
                distance: "1.2 miles away",
                availability: "Available until: 06/14",
                description:
                    "Freshly baked sourdough bread. Made too much and would like to sell half a loaf.",
                price: "\$2.00",
              ),
              const SizedBox(height: 16),
              FoodItemCard(
                imageUrl: "https://randomuser.me/api/portraits/men/75.jpg",
                name: "Pasta Sauce (Unopened)",
                distance: "0.8 miles away",
                availability: "Available until: 06/20",
                description:
                    "Bought an extra jar of organic pasta sauce. Happy to trade for some fresh produce!",
                price: "TRADE",
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    backgroundColor: Colors.green,
                  ),
                  child: Text(
                    "+ Share Your Food",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FoodItemCard extends StatelessWidget {
  final String imageUrl;
  final String name;
  final String distance;
  final String availability;
  final String description;
  final String price;

  const FoodItemCard({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.distance,
    required this.availability,
    required this.description,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(backgroundImage: NetworkImage(imageUrl), radius: 30),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(distance, style: const TextStyle(color: Colors.grey)),
                  Text(
                    availability,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(description),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  price,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    // Handle chat action
                  },
                  child: const Text("Chat"),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    // Handle request action
                  },
                  child: const Text("Request"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
