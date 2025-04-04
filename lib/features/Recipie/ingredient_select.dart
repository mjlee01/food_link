import 'package:flutter/material.dart';
import 'generate_recipe.dart';
import 'recipe_display_view.dart';

class IngredientSelectPage extends StatefulWidget {
  const IngredientSelectPage({super.key});

  @override
  State<IngredientSelectPage> createState() => _IngredientSelectPageState();
}

class _IngredientSelectPageState extends State<IngredientSelectPage> {
  final List<String> allIngredients = [
    'Apples',
    'Bananas',
    'Carrots',
    'Chicken',
    'Eggs',
    'Flour',
    'Garlic',
    'Milk',
    'Onions',
    'Potatoes',
    'Rice',
    'Tomatoes',
    'Bread',
    'Orange',
    'Butter',
    'Honey',
  ];

  final List<String> selectedIngredients = [];
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Ingredients')),
      body: Column(
        children: [
          // Selected ingredients chips
          if (selectedIngredients.isNotEmpty) ...[
            SizedBox(
              height: 60,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemCount: selectedIngredients.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Chip(
                      label: Text(selectedIngredients[index]),
                      onDeleted: () {
                        setState(() {
                          selectedIngredients.removeAt(index);
                        });
                      },
                    ),
                  );
                },
              ),
            ),
            const Divider(),
          ],

          // Ingredients list
          Expanded(
            child: ListView.builder(
              itemCount: allIngredients.length,
              itemBuilder: (context, index) {
                final ingredient = allIngredients[index];
                return CheckboxListTile(
                  title: Text(ingredient),
                  value: selectedIngredients.contains(ingredient),
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        selectedIngredients.add(ingredient);
                      } else {
                        selectedIngredients.remove(ingredient);
                      }
                    });
                  },
                );
              },
            ),
          ),

          // Generate button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: isLoading ? null : _generateRecipe,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.green,
                splashFactory: isLoading ? NoSplash.splashFactory : null,
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 3,
                        backgroundColor: Colors.transparent,
                      ),
                    )
                  : const Text('Generate Recipe'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _generateRecipe() async {
    if (selectedIngredients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one ingredient')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final recipeData = await RecipieGenerator.generateRecipe(
        selectedIngredients,
      );

      if (recipeData != null && mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RecipeDisplayPage(
              recipeName: recipeData['name'] ?? 'Generated Recipe',
              prepTime: recipeData['prepTime'] ?? 'N/A',
              cookTime: recipeData['cookTime'] ?? 'N/A',
              servings: recipeData['servings'] ?? 'N/A',
              ingredients: (recipeData['ingredients'] as List?)?.map((i) {
                if (i is String) return i;
                if (i is Map) {
                  return '${i['amount']} ${i['name']}${i['essential'] == false ? ' (optional)' : ''}';
                }
                return i.toString();
              }).toList() ?? [],
              instructions: (recipeData['instructions'] as List?)?.cast<String>() ?? [],
              notes: recipeData['notes']?.toString(),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error generating recipe: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }
}