import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:food_link/features/Recipie/recipe_model.dart';
import 'package:food_link/features/inventory/inventory_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<InventoryItem>> getGroceryItems() {
    return _db.collection('groceries').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => InventoryItem.fromMap(doc.data()))
          .toList();
    });
  }

  Stream<List<Recipe>> getRecipes() {
    return _db.collection('recipe').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Recipe.fromMap(doc.id, doc.data())).toList();
    });
  }

  Future<void> saveRecipe(Recipe recipe) async {
    await FirebaseFirestore.instance.collection('recipe').add({
      'name': recipe.name,
      'prepTime': recipe.prepTime,
      'cookTime': recipe.cookTime,
      'serving': recipe.serving,
      'ingredient': recipe.ingredient,
      'instruction': recipe.instruction,
      'note': recipe.note,
      'userId': recipe.userId,
    });
  }

  Future<void> deleteRecipe(String recipeId) async {
    await FirebaseFirestore.instance
        .collection('recipe')
        .doc(recipeId)
        .delete();
  }
}
