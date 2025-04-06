import 'dart:ffi';

class Recipe {
  final String name;
  final String prepTime;
  final String cookTime;
  final int serving;
  final List<String> ingredient;
  final List<String> instruction;
  final String note;

  Recipe({
    required this.name,
    required this.prepTime,
    required this.cookTime,
    required this.serving,
    required this.ingredient,
    required this.instruction,
    required this.note,
  });

  factory Recipe.fromMap(Map<String, dynamic> data) {
    return Recipe(
      name: data['name'] ?? 'Unnamed Recipe',
      prepTime: data['prepTime'] ?? '',
      cookTime: data['cookTime'] ?? '',
      serving:
          int.tryParse(data['serving'].toString()) ??
          1, // <-- This handles both string and int
      ingredient: List<String>.from(data['ingredient'] ?? []),
      instruction: List<String>.from(data['instruction'] ?? []),
      note: data['note'] ?? '',
    );
  }
}
