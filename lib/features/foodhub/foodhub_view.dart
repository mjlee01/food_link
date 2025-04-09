import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'food_item.dart';
import 'share_food_modal.dart';
import '../../services/food_service.dart';
import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'chat/chat_modal.dart';
import 'chat/chat_list.dart';

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
  bool _mapControllerInitialized = false;
  final FoodService _foodService = FoodService();
  List<FoodItem> _foodItems = [];
  bool _isLoading = true;
  List<FoodItem> _filteredFoodItems = [];
  bool _showSharedItems = false;
  String _activeFilter = 'All';
  double _filterDistance = 5.0;
  String? _selectedMarkerId;
  final Map<String, Marker> _markersMap = {};

  @override
  void initState() {
    super.initState();
    _configureLocation(); // Configure location settings
    _setInitialPosition(); // Set the initial position of the map
    _loadFoodItems();

    _location.onLocationChanged.listen((locationData) {
      if (_initialPosition == null &&
          locationData.latitude != null &&
          locationData.longitude != null) {
        setState(() {
          _initialPosition = LatLng(
            locationData.latitude!,
            locationData.longitude!,
          );
          // Now that we have a position, update the distances
          _updateItemDistances();
          _applyFilters();
        });
      }
    });
  }

  void _loadFoodItems() {
    if (_showSharedItems) {
      _foodService.getUserFoodItems().listen(
        (items) {
          if (mounted) {
            setState(() {
              _foodItems = items;
              if (_initialPosition != null) {
                _updateItemDistances();
              }
              _applyFilters();
              _isLoading = false;
            });
          }
        },
        onError: (e) {
          setState(() {
            _isLoading = false;
          });
        },
      );
    } else {
      final currentUserId = FirebaseAuth.instance.currentUser?.uid;
      _foodService.getAllFoodItems().listen(
        (items) {
          if (mounted) {
            final filteredItems =
                currentUserId != null
                    ? items
                        .where((item) => item.userId != currentUserId)
                        .toList()
                    : items;
            setState(() {
              _foodItems = filteredItems;
              if (_initialPosition != null) {
                _updateItemDistances();
              }
              _applyFilters();
              _isLoading = false;
            });
          }
        },
        onError: (e) {
          setState(() {
            _isLoading = false;
          });
        },
      );
    }
  }

  void _applyFilters() {
    _filteredFoodItems =
        _foodItems.where((item) {
          if (_showSharedItems) {
            if (_activeFilter == 'All') {
              return true;
            }

            // Only apply price filters in "My Shared Items" view
            if (_activeFilter == 'Free' &&
                !item.price.toUpperCase().contains('FREE')) {
              return false;
            }
            if (_activeFilter == 'For Sale' && !item.price.contains('\$')) {
              return false;
            }
            if (_activeFilter == 'Trade' &&
                !item.price.toUpperCase().contains('TRADE')) {
              return false;
            }
            return true;
          }

          if (_activeFilter != 'All' && _activeFilter != 'Nearby') {
            if (_activeFilter == 'Free' &&
                !item.price.toUpperCase().contains('FREE')) {
              return false;
            }
            if (_activeFilter == 'For Sale' && !item.price.contains('\$')) {
              return false;
            }
            if (_activeFilter == 'Trade' &&
                !item.price.toUpperCase().contains('TRADE')) {
              return false;
            }

            return true;
          }

          if ((_activeFilter == 'Nearby') && _initialPosition != null) {
            final distance = _foodService.calculateDistance(
              _initialPosition!.latitude,
              _initialPosition!.longitude,
              item.latitude,
              item.longitude,
            );
            final distanceInMiles = distance * 0.621371;

            if (distanceInMiles > _filterDistance) {
              return false;
            }
          }

          return true;
        }).toList();
  }

  void _navigateToMarker(
    double latitude,
    double longitude, [
    String? markerId,
  ]) {
    if (_mapControllerInitialized) {
      // Update selected marker if ID is provided
      if (markerId != null && markerId != _selectedMarkerId) {
        setState(() {
          _selectedMarkerId = markerId;
        });
      }

      // First animate camera to the location
      _mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(latitude, longitude),
            zoom: 16.0, // Zoom in closer
          ),
        ),
      );
    }

    // Scroll to top to show the map
    Scrollable.ensureVisible(
      context,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _setInitialPosition() async {
    // Check if location services are enabled
    bool serviceEnabled = await _location.serviceEnabled();

    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    // Check and request location permissions
    PermissionStatus permissionGranted = await _location.hasPermission();

    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    // Get the user's current locatio
    final userLocation = await _location.getLocation();
    if (userLocation.latitude == null || userLocation.longitude == null) {
      return;
    }

    setState(() {
      _initialPosition = LatLng(
        userLocation.latitude!,
        userLocation.longitude!,
      );
    });
  }

  Future<void> _configureLocation() async {
    // Configure location settings
    await _location.changeSettings(
      accuracy: LocationAccuracy.high,
      interval: 1000,
      distanceFilter: 10,
    );
  }

  Set<Marker> _buildMarkers() {
    final markers = <Marker>{};
    _markersMap.clear();

    // Add current location marker
    if (_initialPosition != null) {
      final currentLocationMarker = Marker(
        markerId: const MarkerId('current_location'),
        position: _initialPosition!,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: const InfoWindow(
          title: 'Your Location',
          snippet: 'This is your current location.',
        ),
      );

      markers.add(currentLocationMarker);
      _markersMap['current_location'] = currentLocationMarker;
    }

    // Add food item markers
    for (var item in _filteredFoodItems) {
      final itemId = item.id ?? 'food_${item.name}';
      final isSelected = itemId == _selectedMarkerId;

      final marker = Marker(
        markerId: MarkerId(itemId),
        position: LatLng(item.latitude, item.longitude),
        infoWindow: InfoWindow(title: item.name, snippet: item.price),
        icon:
            isSelected
                ? BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueGreen,
                )
                : BitmapDescriptor.defaultMarker,
      );

      markers.add(marker);
      _markersMap[itemId] = marker;
    }

    return markers;
  }

  void _updateItemDistances() {
    if (_initialPosition == null) return;

    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    for (var item in _foodItems) {
      if (item.userId == currentUserId) {
        item.distanceText = "Your item";
        continue;
      }

      // Calculate distance
      final distance = _foodService.calculateDistance(
        _initialPosition!.latitude,
        _initialPosition!.longitude,
        item.latitude,
        item.longitude,
      );

      // Convert km to miles and format
      final distanceInMiles = distance * 0.621371;

      // Save the formatted distance string in the item
      if (distanceInMiles < 0.1) {
        item.distanceText = "Very near";
      } else if (distanceInMiles < 1) {
        item.distanceText = "${(distanceInMiles * 10).round() / 10} miles away";
      } else {
        item.distanceText = "${distanceInMiles.round()} miles away";
      }
    }
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
                  child:
                      _initialPosition == null
                          ? const Center(child: CircularProgressIndicator())
                          : Stack(
                            children: [
                              Positioned(
                                top: 10,
                                left: 10,
                                child: FloatingActionButton(
                                  mini: true,
                                  heroTag: "chatListButton",
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => const ChatsListPage(),
                                      ),
                                    );
                                  },
                                  backgroundColor: Colors.white,
                                  child: const Icon(
                                    Icons.chat,
                                    color: Colors.green,
                                  ),
                                ),
                              ),
                              // Google Map
                              GoogleMap(
                                initialCameraPosition: CameraPosition(
                                  target: _initialPosition!,
                                  zoom: 12.0,
                                ),
                                myLocationEnabled:
                                    true, // Show the blue dot for current location
                                myLocationButtonEnabled: false,
                                onMapCreated: (GoogleMapController controller) {
                                  _mapController = controller;
                                  _mapControllerInitialized = true;

                                  if (_initialPosition != null) {
                                    _mapController.animateCamera(
                                      CameraUpdate.newLatLng(_initialPosition!),
                                    );
                                  }
                                },
                                markers: _buildMarkers(),
                              ),

                              // Floating Action Buttons (Overlay)
                              Positioned(
                                top: 10,
                                right: 10,
                                child: Column(
                                  children: [
                                    FloatingActionButton(
                                      mini: true,
                                      heroTag: "myLocationButton",
                                      onPressed: () async {
                                        // Get fresh location data
                                        try {
                                          final userLocation =
                                              await _location.getLocation();
                                          if (userLocation.latitude != null &&
                                              userLocation.longitude != null) {
                                            final newPosition = LatLng(
                                              userLocation.latitude!,
                                              userLocation.longitude!,
                                            );

                                            setState(() {
                                              _initialPosition = newPosition;
                                            });

                                            if (_mapControllerInitialized) {
                                              _mapController.animateCamera(
                                                CameraUpdate.newCameraPosition(
                                                  CameraPosition(
                                                    target: newPosition,
                                                    zoom: 15.0,
                                                  ),
                                                ),
                                              );
                                            }
                                          }
                                        } catch (e) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Error getting location. Please try again.',
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                      child: const Icon(Icons.my_location),
                                    ),
                                  ],
                                ),
                              ),

                              // Distance
                              if (_activeFilter == 'Nearby')
                                Positioned(
                                  bottom: 10,
                                  left: 10,
                                  right: 60,
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.8),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        const Text("Distance:"),
                                        Expanded(
                                          child: Slider(
                                            value: _filterDistance,
                                            min: 1,
                                            max: 20,
                                            divisions: 19,
                                            label:
                                                "${_filterDistance.toInt()} miles",
                                            onChanged: (value) {
                                              setState(() {
                                                _filterDistance = value;
                                                _applyFilters();
                                              });
                                            },
                                          ),
                                        ),
                                        Text(
                                          "${_filterDistance.toInt()} miles",
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                ),
              ),
              const SizedBox(height: 16),

              // List View Toggle
              Align(
                alignment: Alignment.center,
                child: ToggleButtons(
                  isSelected: isSelected, // Initial selection state
                  onPressed: (index) {
                    setState(() {
                      // Reset items first
                      _foodItems = [];
                      _filteredFoodItems = [];

                      // Update the selection state
                      for (int i = 0; i < 2; i++) {
                        isSelected[i] = i == index;
                      }
                      _showSharedItems = index == 1;
                      _activeFilter = 'All'; // Reset active filter
                      _isLoading = true;

                      // Add a small delay to ensure UI updates
                      Future.delayed(Duration.zero, () {
                        if (mounted) {
                          _loadFoodItems();
                        }
                      });
                    });
                  },
                  borderRadius: BorderRadius.circular(30),
                  selectedColor: Colors.white,
                  fillColor: Colors.green,
                  color: Colors.black,
                  constraints: const BoxConstraints(
                    minHeight: 40,
                    minWidth: 170,
                  ),
                  children: const [
                    Text("Available Items"),
                    Text("My Shared Items"),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Wrap(
                  spacing: 8, // Spacing between chips
                  children: [
                    FilterChip(
                      label: const Text("All"),
                      selected: _activeFilter == 'All',
                      onSelected: (value) {
                        setState(() {
                          _activeFilter = 'All';
                          _applyFilters();
                        });
                      },
                      selectedColor: Colors.green,
                      backgroundColor: Colors.grey[200],
                      labelStyle: TextStyle(
                        color:
                            _activeFilter == 'All'
                                ? Colors.white
                                : Colors.black,
                      ),
                    ),
                    if (!_showSharedItems)
                      FilterChip(
                        label: const Text("Nearby"),
                        selected: _activeFilter == 'Nearby',
                        onSelected: (value) {
                          setState(() {
                            _activeFilter = 'Nearby';
                            _filterDistance = 1.0; // Reduce distance to 1 mile
                            _applyFilters();
                          });
                        },
                        selectedColor: Colors.green,
                        backgroundColor: Colors.grey[200],
                        labelStyle: const TextStyle(color: Colors.black),
                      ),
                    FilterChip(
                      label: const Text("Free"),
                      selected: _activeFilter == 'Free',
                      onSelected: (value) {
                        setState(() {
                          _activeFilter = 'Free';
                          _applyFilters();
                        });
                      },
                      selectedColor: Colors.green,
                      backgroundColor: Colors.grey[200],
                      labelStyle: const TextStyle(color: Colors.black),
                    ),
                    FilterChip(
                      label: const Text("For Sale"),
                      selected: _activeFilter == 'For Sale',
                      onSelected: (value) {
                        setState(() {
                          _activeFilter = 'For Sale';
                          _applyFilters();
                        });
                      },
                      selectedColor: Colors.green,
                      backgroundColor: Colors.grey[200],
                      labelStyle: const TextStyle(color: Colors.black),
                    ),
                    FilterChip(
                      label: const Text("Trade"),
                      selected: _activeFilter == 'Trade',
                      onSelected: (value) {
                        setState(() {
                          _activeFilter = 'Trade';
                          _applyFilters();
                        });
                      },
                      selectedColor: Colors.green,
                      backgroundColor: Colors.grey[200],
                      labelStyle: const TextStyle(color: Colors.black),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Food Item Cards
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredFoodItems.isEmpty
                  ? Center(
                    child: Text(
                      _showSharedItems
                          ? 'You haven\'t shared any food items yet'
                          : 'No food items available',
                    ),
                  )
                  : ListView.separated(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: _filteredFoodItems.length,
                    separatorBuilder:
                        (context, index) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final item = _filteredFoodItems[index];

                      // Use different card layout based on view
                      return _showSharedItems
                          ? MySharedFoodItemCard(
                            imageUrl: item.imageUrl,
                            name: item.name,
                            description: item.description,
                            price: item.price,
                            id: item.id,
                          )
                          : FoodItemCard(
                            imageUrl: item.imageUrl,
                            name: item.name,
                            distance: item.distanceText,
                            availability: item.availability,
                            description: item.description,
                            price: item.price,
                            id: item.id,
                            userId: item.userId,
                            latitude: item.latitude,
                            longitude: item.longitude,
                            onLocationTap:
                                (lat, lng) =>
                                    _navigateToMarker(lat, lng, item.id),
                          );
                    },
                  ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Check if location is available
                    if (_initialPosition == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Location is not available. Please try again.',
                          ),
                        ),
                      );
                      return;
                    }

                    // Show modal bottom sheet with blur effect
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true, // Makes the modal expandable
                      backgroundColor:
                          Colors
                              .transparent, // Transparent background for blur effect
                      builder:
                          (context) => BackdropFilter(
                            filter: ImageFilter.blur(
                              sigmaX: 5,
                              sigmaY: 5,
                            ), // Blur effect
                            child: ShareFoodModal(
                              onSuccess: () {
                                // Reload food items
                                setState(() {
                                  _isLoading = true;
                                });
                                _loadFoodItems();
                              },
                              latitude: _initialPosition!.latitude,
                              longitude: _initialPosition!.longitude,
                            ),
                          ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    backgroundColor: Colors.green,
                  ),
                  child: const Text(
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

class FoodItemCard extends StatefulWidget {
  final String imageUrl;
  final String name;
  final String distance;
  final String availability;
  final String description;
  final String price;
  final String userId;
  final String? id;
  final double latitude;
  final double longitude;
  final Function(double lat, double lng)? onLocationTap;

  const FoodItemCard({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.distance,
    required this.availability,
    required this.description,
    required this.price,
    required this.userId,
    required this.latitude,
    required this.longitude,
    this.onLocationTap,
    this.id,
  });

  @override
  State<FoodItemCard> createState() => _FoodItemCardState();
}

class _FoodItemCardState extends State<FoodItemCard> {
  final FoodService _foodService = FoodService();
  String _userImageUrl = "https://randomuser.me/api/portraits/men/0.jpg";
  bool _isLoadingImage = true;
  String _userName = "Loading...";
  bool _isLoadingUserInfo = true;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    try {
      setState(() {
        _isLoadingUserInfo = true;
        _isLoadingImage = true;
      });

      final imageUrl = await _foodService.getUserProfileImage(widget.userId);

      final userProfile = await _foodService.getUserProfile(widget.userId);
      final userName = userProfile?['name'] ?? 'Food Owner';

      if (mounted) {
        setState(() {
          _userImageUrl = imageUrl;
          _userName = userName;
          _isLoadingUserInfo = false;
          _isLoadingImage = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingUserInfo = false;
          _isLoadingImage = false;
        });
      }
    }
  }

  bool _isExpired(String availabilityText) {
    try {
      final regex = RegExp(r'(\d{1,2})\/(\d{1,2})');
      final match = regex.firstMatch(availabilityText);

      if (match != null) {
        final month = int.parse(match.group(1)!);
        final day = int.parse(match.group(2)!);

        final now = DateTime.now();
        final availableUntil = DateTime(now.year, month, day);

        if (now.difference(availableUntil).inDays > 330 && month > now.month) {
          final nextYearDate = DateTime(now.year + 1, month, day);
          return now.isAfter(nextYearDate);
        }

        return now.isAfter(availableUntil);
      }
    } catch (e) {
      print('Error parsing date: $e');
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (widget.onLocationTap != null) {
          widget.onLocationTap!(widget.latitude, widget.longitude);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location not available')),
          );
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _isLoadingImage
                  ? CircleAvatar(
                    radius: 30,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                  : CircleAvatar(
                    backgroundImage: NetworkImage(_userImageUrl),
                    radius: 30,
                  ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        // Location with map marker icon
                        Expanded(
                          flex: 1,
                          child: Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                size: 14,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  widget.distance,
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Availability with calendar icon
                        Expanded(
                          flex: 1,
                          child: Row(
                            children: [
                              const Icon(
                                Icons.calendar_today,
                                size: 14,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  widget.availability,
                                  style: TextStyle(
                                    color:
                                        _isExpired(widget.availability)
                                            ? Colors.red
                                            : Colors.grey,
                                    fontSize: 12,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.description,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 80),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.price,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color:
                            widget.price.contains('FREE')
                                ? Colors.green
                                : widget.price.contains('TRADE')
                                ? Colors.orange
                                : Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (BuildContext context) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            },
                          );
                          try {
                            // Try to find existing chat first
                            final existingChat = await _foodService
                                .findExistingChatWithUser(widget.userId);

                            // Close loading dialog
                            Navigator.pop(context);

                            if (existingChat != null) {
                              // Navigate to existing chat
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => ChatPage(
                                        recipientId:
                                            existingChat['otherUserId'],
                                        recipientName:
                                            existingChat['otherUserName'],
                                        foodItemName:
                                            existingChat['foodItemName'],
                                        foodItemId: existingChat['foodItemId'],
                                      ),
                                ),
                              );
                            } else {
                              // Create new chat
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => ChatPage(
                                        recipientId: widget.userId,
                                        recipientName: _userName,
                                        foodItemName: widget.name,
                                        foodItemId: widget.id ?? 'unknown',
                                      ),
                                ),
                              );
                            }
                          } catch (e) {
                            // Close loading dialog on error
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error opening chat: $e')),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          animationDuration: Duration.zero,
                        ),
                        child: const Text("Chat"),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (BuildContext context) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            },
                          );
                          try {
                            // Check for existing chat first
                            final existingChat = await _foodService
                                .findExistingChatWithUser(widget.userId);
                            String foodItemId = widget.id ?? 'unknown';
                            String recipientName = _userName;

                            if (existingChat != null) {
                              // Use existing chat info
                              foodItemId = existingChat['foodItemId'];
                              recipientName = existingChat['otherUserName'];
                            }

                            // Send the message
                            await _foodService.sendMessage(
                              receiverId: widget.userId,
                              text:
                                  "Hey, I'm interested in your ${widget.name} that you're offering ${widget.price.contains('FREE')
                                      ? 'for free'
                                      : widget.price.contains('TRADE')
                                      ? 'to trade'
                                      : 'to sell'}. Can we discuss this?",
                              foodItemId: foodItemId,
                            );

                            // Close loading dialog
                            Navigator.pop(context);

                            // Navigate to chat
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => ChatPage(
                                      recipientId: widget.userId,
                                      recipientName: recipientName,
                                      foodItemName:
                                          existingChat != null
                                              ? existingChat['foodItemName']
                                              : widget.name,
                                      foodItemId: foodItemId,
                                    ),
                              ),
                            );

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Request sent!')),
                            );
                          } catch (e) {
                            // Close loading dialog on error
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error sending request: $e'),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          animationDuration: Duration.zero,
                        ),
                        child: const Text("Request"),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MySharedFoodItemCard extends StatelessWidget {
  final String imageUrl;
  final String name;
  final String description;
  final String price;
  final String? id;

  const MySharedFoodItemCard({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.description,
    required this.price,
    this.id,
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 80),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    price,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color:
                          price.contains('FREE')
                              ? Colors.green
                              : price.contains('TRADE')
                              ? Colors.orange
                              : Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Edit the food item
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Edit feature coming soon'),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        side: const BorderSide(
                          color: Colors.amber,
                          width: 1,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        backgroundColor: Colors.amber,
                      ),
                      child: const Text("Edit"),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Delete the food item
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Delete feature coming soon'),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        side: const BorderSide(
                          color: Colors.red,
                          width: 1,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        backgroundColor: Colors.red,
                      ),
                      child: const Text("Delete"),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
