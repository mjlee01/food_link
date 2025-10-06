import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'food_item.dart';
import '../../services/food_service.dart';

class ShareFoodModal extends StatefulWidget {
  final Function onSuccess;
  final double latitude;
  final double longitude;

  const ShareFoodModal({
    super.key,
    required this.onSuccess,
    required this.latitude,
    required this.longitude,
  });

  @override
  State<ShareFoodModal> createState() => _ShareFoodModalState();
}

class _ShareFoodModalState extends State<ShareFoodModal> {
  final _formKey = GlobalKey<FormState>();
  final _foodService = FoodService();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _availabilityController = TextEditingController();
  final _addressController = TextEditingController();

  String _selectedPriceType = 'FREE';
  final _priceController = TextEditingController();
  bool _isLoading = false;
  String? _selectedFoodItem;
  List<String> _userFoodItems = [];

  // New fields
  bool _isPickup = true;
  bool _isDelivery = false;
  DateTime _availableUntil = DateTime.now().add(const Duration(days: 3));
  LatLng _pickupLocation = const LatLng(0, 0);
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    _fetchUserFoodItems();
    _pickupLocation = LatLng(widget.latitude, widget.longitude);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _availabilityController.dispose();
    _priceController.dispose();
    _addressController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _saveFoodItem() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('You need to be logged in to share food'),
            ),
          );
          return;
        }

        String price;
        if (_selectedPriceType == 'FOR SALE') {
          price = '\$${_priceController.text}';
        } else {
          price = _selectedPriceType;
        }

        // Format the availability text based on date and pickup options
        String availabilityText =
            'Available until: ${_availableUntil.month}/${_availableUntil.day}';
        if (_isPickup && _isDelivery) {
          availabilityText += ' (Pickup/Delivery)';
        } else if (_isPickup) {
          availabilityText += ' (Pickup only)';
        } else if (_isDelivery) {
          availabilityText += ' (Delivery only)';
        }

        final foodItem = FoodItem(
          userId: user.uid,
          name: _nameController.text,
          description: _descriptionController.text,
          price: price,
          availability: availabilityText,
          imageUrl: _getRandomFoodImage(_nameController.text),
          latitude: _pickupLocation.latitude,
          longitude: _pickupLocation.longitude,
        );

        await _foodService.addFoodItem(foodItem);

        if (mounted) {
          widget.onSuccess();
          Navigator.pop(context); // Close the modal
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Food item shared successfully!')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error sharing food item: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  void _fetchUserFoodItems() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        _foodService
            .getUserInventory(user.uid)
            .listen(
              (items) {
                if (mounted) {
                  final uniqueItems = <String>{};
                  for (var item in items) {
                    uniqueItems.add(item.name);
                  }
                  setState(() {
                    _userFoodItems = uniqueItems.toList();
                    _selectedFoodItem = null;
                  });
                }
              },
              onError: (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error fetching food items: $e')),
                  );
                }
              },
            );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching food items: $e')),
        );
      }
    }
  }

  String _getRandomFoodImage(String foodName) {
    final foodImages = {
      'apple': 'https://images.unsplash.com/photo-1568702846914-96b305d2aaeb',
      'bread': 'https://images.unsplash.com/photo-1549931319-a545dcf3bc73',
      'pasta': 'https://images.unsplash.com/photo-1627469542533-5e28c7a0ad7e',
      'soup': 'https://images.unsplash.com/photo-1547592166-23ac45744acd',
      'salad': 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c',
      'vegetable':
          'https://images.unsplash.com/photo-1566385101042-1a0aa0c1268c',
      'chicken': 'https://images.unsplash.com/photo-1527477396000-e27163b481c2',
      'beef': 'https://images.unsplash.com/photo-1602632032022-a7d18b503c6f',
      'fish': 'https://images.unsplash.com/photo-1535424921017-85119f91e5a1',
      'fruit': 'https://images.unsplash.com/photo-1519996529931-28324d5a630e',
      'dairy': 'https://images.unsplash.com/photo-1550583724-b2692b85b150',
      'egg': 'https://images.unsplash.com/photo-1587486913049-53fc88980cfc',
      'rice': 'https://images.unsplash.com/photo-1536304993881-ff6e9eefa2a6',
    };

    // Generic food images for fallback
    final genericFoodImages = [
      'https://images.unsplash.com/photo-1546069901-ba9599a7e63c', // Salad
      'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38', // Pizza
      'https://images.unsplash.com/photo-1563379926898-05f4575a45d8', // Vegetables
      'https://images.unsplash.com/photo-1567620905732-2d1ec7ab7445', // Pancakes
      'https://images.unsplash.com/photo-1540189549336-e6e99c3679fe', // Veg Plate
    ];

    // Convert name to lowercase for easier matching
    final lowerName = foodName.toLowerCase();

    // Check if the food name contains any of our known food types
    for (var foodType in foodImages.keys) {
      if (lowerName.contains(foodType)) {
        return foodImages[foodType]!;
      }
    }

    // If no match, use a random generic food image
    final random = DateTime.now().second % genericFoodImages.length;
    return genericFoodImages[random];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 16.0,
        left: 16.0,
        right: 16.0,
        // Add padding to avoid the keyboard
        bottom: MediaQuery.of(context).viewInsets.bottom + 16.0,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
      ),
      child:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Share Food Item',
                            style: TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedFoodItem,
                        decoration: const InputDecoration(
                          labelText: 'Select from Your Food Items',
                          hintText: 'Choose a food item to share',
                          border: OutlineInputBorder(),
                        ),
                        items:
                            _userFoodItems.isEmpty
                                ? [
                                  const DropdownMenuItem<String>(
                                    value: null,
                                    child: Text(
                                      'No items available - Add manually',
                                    ),
                                  ),
                                ]
                                : _userFoodItems.map<DropdownMenuItem<String>>((
                                  String item,
                                ) {
                                  return DropdownMenuItem<String>(
                                    value: item,
                                    child: Text(item),
                                  );
                                }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedFoodItem = newValue;
                            if (newValue != null) {
                              _nameController.text = newValue;
                            }
                          });
                        },
                        validator: (value) {
                          if (_nameController.text.isEmpty) {
                            return 'Please select or enter a food name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      // Name field if not selected from dropdown
                      if (_selectedFoodItem == null)
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Food Item Name',
                            hintText: 'e.g., Organic Apples (5 pcs)',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a food name';
                            }
                            return null;
                          },
                        ),
                      const SizedBox(height: 16),
                      // Description field (new)
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          hintText:
                              'Describe your item (condition, why sharing, etc.)',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a description';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedPriceType,
                        decoration: const InputDecoration(
                          labelText: 'Listing Type',
                          border: OutlineInputBorder(),
                        ),
                        items:
                            ['FREE', 'FOR SALE', 'TRADE'].map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            _selectedPriceType = newValue!;
                          });
                        },
                      ),
                      if (_selectedPriceType == 'FOR SALE') ...[
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _priceController,
                          decoration: const InputDecoration(
                            labelText: 'Price (\$)',
                            hintText: 'e.g., 2.00',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.attach_money),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a price';
                            }
                            if (double.tryParse(value) == null) {
                              return 'Please enter a valid number';
                            }
                            return null;
                          },
                        ),
                      ],
                      const SizedBox(height: 16),

                      // Set Pickup Location (new)
                      const Text(
                        'Set Pickup Location',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 150,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Stack(
                            children: [
                              GoogleMap(
                                initialCameraPosition: CameraPosition(
                                  target: _pickupLocation,
                                  zoom: 15,
                                ),
                                onMapCreated: (controller) {
                                  _mapController = controller;
                                },
                                onCameraMove: (position) {
                                  setState(() {
                                    _pickupLocation = position.target;
                                  });
                                },
                                myLocationEnabled: true,
                                myLocationButtonEnabled: false,
                              ),
                              Center(
                                child: Icon(
                                  Icons.location_pin,
                                  color: Colors.red,
                                  size: 36,
                                ),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: FloatingActionButton.small(
                                  onPressed: () {
                                    _mapController?.animateCamera(
                                      CameraUpdate.newLatLng(
                                        LatLng(
                                          widget.latitude,
                                          widget.longitude,
                                        ),
                                      ),
                                    );
                                  },
                                  heroTag: "mapControlButton",
                                  backgroundColor: Colors.white,
                                  child: Icon(
                                    Icons.my_location,
                                    color: Colors.blue,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _addressController,
                        decoration: const InputDecoration(
                          labelText: 'Address',
                          hintText: 'Or enter address manually',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Pickup Options (new)
                      const Text(
                        'Pickup Options',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          Checkbox(
                            value: _isPickup,
                            onChanged: (value) {
                              setState(() {
                                _isPickup = value ?? true;
                                // Ensure at least one option is selected
                                if (!_isPickup && !_isDelivery) {
                                  _isDelivery = true;
                                }
                              });
                            },
                          ),
                          const Text('Pickup'),
                          const SizedBox(width: 20),
                          Checkbox(
                            value: _isDelivery,
                            onChanged: (value) {
                              setState(() {
                                _isDelivery = value ?? false;
                                // Ensure at least one option is selected
                                if (!_isPickup && !_isDelivery) {
                                  _isPickup = true;
                                }
                              });
                            },
                          ),
                          const Text('Delivery'),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Available Until (new)
                      const Text(
                        'Available Until',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () async {
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: _availableUntil,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(
                              const Duration(days: 30),
                            ),
                          );
                          if (picked != null) {
                            setState(() {
                              _availableUntil = picked;
                            });
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 15,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade400),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${_availableUntil.month}/${_availableUntil.day}/${_availableUntil.year}',
                                style: TextStyle(fontSize: 16),
                              ),
                              const Icon(Icons.calendar_today),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _saveFoodItem,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            backgroundColor: Colors.green,
                          ),
                          child: const Text(
                            'Share Food',
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
