import 'package:flutter/material.dart';
import 'package:food_link/data/services/firestore_services.dart';
import 'package:food_link/features/inventory/inventory_model.dart';

class GroceryController extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  List<InventoryItem> groceries = [];
  void fetchGroceries() {
    _firestoreService.getGroceryItems().listen((items) {
      groceries = items;
      notifyListeners();
    });
  }
}