import 'package:flutter/material.dart';
import 'ingredient_select.dart';  // Make sure this import path is correct

class RecipePage extends StatelessWidget {
  const RecipePage({super.key});

  // Sample recipe data - replace with your actual data
  final List<Map<String, dynamic>> recipes = const [
    {'name': 'Vegetable Stir Fry', 'date': '2023-10-15'},
    {'name': 'Chicken Curry', 'date': '2023-10-10'},
    {'name': 'Pasta Carbonara', 'date': '2023-10-05'},
    {'name': 'Avocado Toast', 'date': '2023-09-28'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('My Recipes', style: TextStyle(color: Colors.green)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.green),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: recipes.length,
        itemBuilder: (context, index) {
          return Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              title: Text(
                recipes[index]['name'],
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Created: ${recipes[index]['date']}',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ),
              trailing: const Icon(Icons.chevron_right, color: Colors.green),
              onTap: () {
                // Add navigation to recipe detail page if needed
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => IngredientSelectPage()),
          );
        },
      ),
    );
  }
}