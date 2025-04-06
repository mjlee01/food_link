import 'package:flutter/material.dart';
import 'package:food_link/data/services/firestore_services.dart';
import 'package:food_link/features/Recipie/recipe_model.dart';

class RecipieController extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  List<Recipe> recipes = [];
  void fetchRecipes() {
    _firestoreService.getRecipes().listen((items) {
      recipes = items;
      notifyListeners();
    });
  }
}