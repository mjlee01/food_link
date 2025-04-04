import 'package:flutter/material.dart';

class RecipeDisplayPage extends StatelessWidget {
  final String recipeName;
  final String prepTime;
  final String cookTime;
  final String servings;
  final List<String> ingredients;
  final List<String> instructions;
  final String? notes;

  const RecipeDisplayPage({
    super.key,
    required this.recipeName,
    required this.prepTime,
    required this.cookTime,
    required this.servings,
    required this.ingredients,
    required this.instructions,
    this.notes,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(recipeName),
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
        body: TabBarView(
          children: [
            // Overview Tab
            _buildOverviewTab(),

            // Ingredients Tab
            _buildIngredientsTab(),

            // Steps Tab
            _buildInstructionsTab(),
          ],
        ),
      ),
    );
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
              recipeName,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 32),
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildInfoRow(Icons.timer, "Prep Time", prepTime),
                  const Divider(),
                  _buildInfoRow(Icons.timer_outlined, "Cook Time", cookTime),
                  const Divider(),
                  _buildInfoRow(Icons.people, "Servings", servings),
                ],
              ),
            ),
          ),
          if (notes != null && notes!.isNotEmpty) ...[
            const SizedBox(height: 24),
            Card(
              elevation: 4,
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
                    Text(notes!, style: const TextStyle(fontSize: 16)),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildIngredientsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: ingredients.length,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                const Icon(Icons.circle, size: 8, color: Colors.green),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    ingredients[index],
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
    itemCount: instructions.length,
    itemBuilder: (context, index) {
      // Remove any existing numbering from the instruction text
      final instructionText = instructions[index].replaceAll(RegExp(r'^\d+\.\s*'), '');
      
      return Card(
        margin: const EdgeInsets.symmetric(vertical: 8),
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
              Text(
                instructionText, // Use the cleaned text
                style: const TextStyle(fontSize: 16),
              ),
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
