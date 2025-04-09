import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'food_item.dart';
import '../../services/food_service.dart';
import 'package:location/location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ShareFoodPage extends StatefulWidget {
  const ShareFoodPage({super.key});

  @override
  State<ShareFoodPage> createState() => _ShareFoodPageState();
}

class _ShareFoodPageState extends State<ShareFoodPage> {
  final _formKey = GlobalKey<FormState>();
  final _foodService = FoodService();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _availabilityController = TextEditingController();
  final _imageUrlController = TextEditingController();

  String _selectedPriceType = 'FREE';
  final _priceController = TextEditingController();
  bool _isLoading = false;
  late LatLng _userLocation;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _availabilityController.dispose();
    _imageUrlController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  // Get current location
  Future<void> _getCurrentLocation() async {
    final location = Location();

    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    PermissionStatus permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    final locationData = await location.getLocation();
    setState(() {
      _userLocation = LatLng(locationData.latitude!, locationData.longitude!);
    });
  }

  // Save food item to Firestore
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

        final foodItem = FoodItem(
          userId: user.uid,
          name: _nameController.text,
          description: _descriptionController.text,
          price: price,
          availability: _availabilityController.text,
          imageUrl:
              _imageUrlController.text.isEmpty
                  ? 'https://randomuser.me/api/portraits/men/${DateTime.now().second % 90}.jpg'
                  : _imageUrlController.text,
          latitude: _userLocation.latitude,
          longitude: _userLocation.longitude,
        );

        await _foodService.addFoodItem(foodItem);

        // Show success message and navigate back
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Food item shared successfully!')),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        // Show error message
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Share Your Food'),
        backgroundColor: Colors.green,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Food Name',
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
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          hintText: 'Describe your food item',
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
                      TextFormField(
                        controller: _availabilityController,
                        decoration: const InputDecoration(
                          labelText: 'Availability',
                          hintText: 'e.g., Available until: 06/15',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter availability';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedPriceType,
                        decoration: const InputDecoration(
                          labelText: 'Price Type',
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
                      TextFormField(
                        controller: _imageUrlController,
                        decoration: const InputDecoration(
                          labelText: 'Image URL (Optional)',
                          hintText:
                              'Enter image URL or leave empty for default',
                          border: OutlineInputBorder(),
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
