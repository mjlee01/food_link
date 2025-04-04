import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:food_link/features/inventory/inventory_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<InventoryItem>> getGroceryItems() {
    return _db.collection('groceries').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => InventoryItem.fromMap(doc.data())).toList();
    });
  }
}