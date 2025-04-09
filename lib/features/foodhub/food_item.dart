class FoodItem {
  final String? id;
  final String userId;
  final String name;
  final String description;
  final String price;
  final String availability;
  final String imageUrl;
  final double latitude;
  final double longitude;
  final DateTime createdAt;
  String distanceText = "";

  FoodItem({
    this.id,
    required this.userId,
    required this.name,
    required this.description,
    required this.price,
    required this.availability,
    required this.imageUrl,
    required this.latitude,
    required this.longitude,
    DateTime? createdAt,
  }) : this.createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'description': description,
      'price': price,
      'availability': availability,
      'imageUrl': imageUrl,
      'latitude': latitude,
      'longitude': longitude,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory FoodItem.fromMap(Map<String, dynamic> map, String id) {
    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) {
        return double.tryParse(value) ?? 0.0;
      }
      return 0.0;
    }

    return FoodItem(
      id: id,
      userId: map['userId'] ?? '',
      name: map['name'] ?? 'Unnamed Food Item',
      description: map['description'] ?? 'No description provided',
      price: map['price'] ?? 'FREE',
      availability: map['availability'] ?? 'Available now',
      imageUrl: map['imageUrl'] ?? 'https://via.placeholder.com/150',
      latitude: parseDouble(map['latitude']), // Use helper function
      longitude: parseDouble(map['longitude']), // Use helper function
      createdAt:
          map['createdAt'] != null
              ? DateTime.parse(map['createdAt'])
              : DateTime.now(),
    );
  }
}
