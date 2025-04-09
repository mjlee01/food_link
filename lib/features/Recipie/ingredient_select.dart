import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:food_link/features/Recipie/recipe_model.dart';
import 'package:food_link/features/inventory/inventory_model.dart';
import 'generate_recipe.dart';
import 'recipe_display_view.dart';

class IngredientSelectPage extends StatefulWidget {
  final List<String> initialIngredient;

  const IngredientSelectPage({super.key, this.initialIngredient = const []});

  @override
  State<IngredientSelectPage> createState() => _IngredientSelectPageState();
}

class _IngredientSelectPageState extends State<IngredientSelectPage> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  late Recipe recipeData;
  late List<String> selectedIngredients; // Change from final to late
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    selectedIngredients = List.from(
      widget.initialIngredient,
    ); // Initialize with passed ingredients
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Ingredients')),
      body: StreamBuilder<QuerySnapshot>(
        stream: _db.collection('groceries').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No ingredients found'));
          }

          final ingredients =
              snapshot.data!.docs.map((doc) {
                return InventoryItem.fromMap(
                  doc.data() as Map<String, dynamic>,
                );
              }).toList();

          return Column(
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
                  itemCount: ingredients.length,
                  itemBuilder: (context, index) {
                    final ingredient = ingredients[index];
                    return CheckboxListTile(
                      title: Text(ingredient.name),
                      value: selectedIngredients.contains(ingredient.name),
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            selectedIngredients.add(ingredient.name);
                          } else {
                            selectedIngredients.remove(ingredient.name);
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
                  child:
                      isLoading
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
          );
        },
      ),

      //
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
            builder:
                (context) =>
                    RecipeDisplayPage(recipe: recipeData, isNewRecipe: true),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error generating recipe: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }
}
