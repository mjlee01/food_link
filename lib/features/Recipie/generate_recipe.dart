import 'package:food_link/features/Recipie/recipe_model.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:convert';

class RecipieGenerator {
  static Future<Recipe?> generateRecipe(List<String?> ingredients) async {
    final validIngredients = ingredients
        .where((ingredient) => ingredient != null && ingredient.isNotEmpty)
        .toList();
    final ingredientsString = validIngredients.join(', ');

    // Modified prompt to match your exact model structure
    final prompt = '''
    Create a detailed recipe using ONLY these ingredients: $ingredientsString.
    
    Respond in EXACTLY this JSON format:
    {
      "name": "Recipe Name",
      "prepTime": "X minutes",
      "cookTime": "X minutes",
      "serving": "X",
      "ingredient": [
        "Ingredient 1 with amount",
        "Ingredient 2 with amount"
      ],
      "instruction": [
        "Step 1 description",
        "Step 2 description"
      ],
      "note": "Optional note"
    }
    
    Important:
    1. Use "ingredient" (singular) not "ingredients"
    2. Use "instruction" (singular) not "instructions"
    3. Include amounts directly in the ingredient strings
    4. Keep all field names exactly as specified
    ''';

    final apiKey = 'AIzaSyCj578QUFNzijXPpjRKCEjxeNEpSoQ59R4';
    final model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
    );

    try {
      final response = await model.generateContent([Content.text(prompt)]);
      final rawResponse = response.text ?? '';
      
      final jsonMap = _parseRecipeResponse(rawResponse);
      if (jsonMap == null) return null;
      
      return Recipe.fromMap(jsonMap);
    } catch (e) {
      print('Error generating recipe: $e');
      return null;
    }
  }

  static Map<String, dynamic>? _parseRecipeResponse(String rawResponse) {
    try {
      // First try to parse the entire response as JSON
      try {
        return jsonDecode(rawResponse) as Map<String, dynamic>;
      } catch (_) {}

      // Fallback to extracting JSON from markdown-style blocks
      final jsonPattern = RegExp(r'```(?:json)?\n({.*?})\n```', dotAll: true);
      final match = jsonPattern.firstMatch(rawResponse);
      if (match != null) {
        return jsonDecode(match.group(1)!);
      }

      // Final fallback - look for any JSON-like structure
      final looseJsonPattern = RegExp(r'\{.*\}', dotAll: true);
      final looseMatch = looseJsonPattern.firstMatch(rawResponse);
      if (looseMatch != null) {
        return jsonDecode(looseMatch.group(0)!);
      }

      return null;
    } catch (e) {
      print('Error parsing recipe response: $e');
      return null;
    }
  }
}