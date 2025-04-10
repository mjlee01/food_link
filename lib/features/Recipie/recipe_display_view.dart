import 'package:flutter/material.dart';
import 'package:food_link/data/services/firestore_services.dart';
import 'package:food_link/features/Recipie/recipe_model.dart';
import 'package:food_link/utils/constants/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RecipeDisplayPage extends StatelessWidget {
  final Recipe recipe;
  final bool isNewRecipe; // Add this flag

  const RecipeDisplayPage({
    super.key,
    required this.recipe,
    this.isNewRecipe = false, // Default to false
  });


  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(recipe.name),
          actions: [
            if (!isNewRecipe) // Only show delete button when recipe is loaded
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _showDeleteConfirmation(context),
              ),
          ],
          bottom: const TabBar(
            indicatorColor: Colors.green,
            labelColor: Colors.green,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(icon: Icon(Icons.info), text: "Overview"),
              Tab(icon: Icon(Icons.shopping_basket), text: "Ingredients"),
              Tab(icon: Icon(Icons.list), text: "Steps"),
            ],
          ),
        ),
        body: Stack(
          children: [
            TabBarView(
              children: [
                _buildOverviewTab(),
                _buildIngredientsTab(),
                _buildInstructionsTab(),
              ],
            ),
            // Positioned save button only for new recipes
            if (isNewRecipe) _buildSaveButton(context),
          ],
        ),
      ),
    );
  }

  Future<void> _showDeleteConfirmation(BuildContext context) async {
    return showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Recipe'),
            content: Text('Are you sure you want to delete "${recipe.name}"?'),
            actions: [
              TextButton(
                style: ButtonStyle(
                  shape: WidgetStateProperty.resolveWith(
                    (context) => RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(color: FLColors.darkGrey),
                    ),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                style: ButtonStyle(
                  backgroundColor: WidgetStateColor.resolveWith(
                    (context) => FLColors.error,
                  ),
                ),
                onPressed: () async {
                  Navigator.pop(context); // Close the dialog
                  try {
                    final firestoreService = FirestoreService();
                    await firestoreService.deleteRecipe(recipe.id);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('"${recipe.name}" deleted successfully'),
                      ),
                    );

                    Navigator.pop(context); // Go back to previous screen
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error deleting recipe: $e')),
                    );
                  }
                },
                child: Text(
                  'Delete',
                  style: TextStyle(color: FLColors.textWhite),
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    return Positioned(
      bottom: 20,
      right: 20,
      child: FloatingActionButton(
        backgroundColor: Colors.green,
        child: const Icon(Icons.save, color: Colors.white),
        onPressed: () => _saveRecipe(context),
      ),
    );
  }

  Future<void> _saveRecipe(BuildContext context) async {
    try {
      final firestoreService = FirestoreService();
      final String userId = FirebaseAuth.instance.currentUser!.uid;
      
      recipe.userId = userId;
      await firestoreService.saveRecipe(recipe);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Recipe saved successfully!'), backgroundColor: FLColors.info,),
      );

      // go back 2 pages
      Navigator.of(context)
      ..pop() // pop recipe details page
      ..pop(); // pop ingredient select page
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error saving recipe: $e')));
    }
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: CircleAvatar(
              radius: 80,
              backgroundColor: Colors.grey[200],
              child: const Icon(
                Icons.restaurant,
                size: 60,
                color: Colors.green,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Text(
              recipe.name,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 32),
          Card(
            elevation: 4,
            color: Colors.grey[100],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildInfoRow(Icons.timer, "Prep Time", recipe.prepTime),
                  const Divider(),
                  _buildInfoRow(
                    Icons.timer_outlined,
                    "Cook Time",
                    recipe.cookTime,
                  ),
                  const Divider(),
                  _buildInfoRow(
                    Icons.people,
                    "Servings",
                    recipe.serving.toString(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Card(
            elevation: 4,
            color: Colors.grey[100],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Notes & Serving Suggestions",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(recipe.note, style: const TextStyle(fontSize: 16)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: recipe.ingredient.length,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          color: Colors.grey[100],
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                const Icon(Icons.circle, size: 8, color: Colors.green),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    recipe.ingredient[index],
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInstructionsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: recipe.instruction.length,
      itemBuilder: (context, index) {
        final instructionText = recipe.instruction[index].replaceAll(
          RegExp(r'^\d+\.\s*'),
          '',
        );
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          color: Colors.grey[100],
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Step ${index + 1}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 8),
                Text(instructionText, style: const TextStyle(fontSize: 16)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.green),
          const SizedBox(width: 16),
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const Spacer(),
          Text(value, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
