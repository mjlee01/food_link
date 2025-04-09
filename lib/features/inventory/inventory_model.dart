import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get_utils/src/extensions/export.dart';

class InventoryItem {
  String name, category, unit, note, imageUrl;
  DateTime expiryDate;
  int quantity;

  InventoryItem({
    required this.name,
    required this.category,
    required this.expiryDate,
    required this.quantity,
    required this.unit,
    this.note = '',
    this.imageUrl = '',
  });

  factory InventoryItem.fromMap(Map<String, dynamic> data) {
    return InventoryItem(
      name: data['name'],
      category: data['category'],
      expiryDate: (data['expiry_date'] as Timestamp).toDate(),
      quantity: data['quantity'],
      unit: data['unit'],
      note: data['note'] ?? '',
      imageUrl: data['image_url'] ?? 'No Image',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'added_date': Timestamp.now(),
      'category': category,
      'expiry_date': Timestamp.fromDate(expiryDate),
      'name': name,
      'note': note,
      'quantity': quantity,
      'unit': unit,
      'image_url': imageUrl,
    };
  }
  
}
