import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:convert'; // Add this import for jsonDecode

class RecipieGenerator {
  static Future<Map<String, dynamic>?> generateRecipe(List<String?> ingredients) async {
    final validIngredients = ingredients
        .where((ingredient) => ingredient != null && ingredient.isNotEmpty)
        .toList();
    final ingredientsString = validIngredients.join(', ');

    // Structured prompt for consistent output
    final prompt = '''
    Create a detailed recipe using ONLY these ingredients: $ingredientsString.
    
    Respond in EXACTLY this JSON format (include the --- separators):
    
    ---
    {
      "name": "Creative Recipe Name",
      "prepTime": "X minutes",
      "cookTime": "X minutes",
      "totalTime": "X minutes",
      "servings": "X servings",
      "ingredients": [
        {"name": "Ingredient 1", "amount": "X unit", "essential": true},
        {"name": "Ingredient 2", "amount": "X unit", "essential": false}
      ],
      "instructions": [
        "Step 1 description",
        "Step 2 description"
      ],
      "notes": "Optional serving suggestions or variations"
    }
    ---
    
    Guidelines:
    1. Only include ingredients from the provided list plus MAXIMUM 3 common pantry items (mark non-provided items as essential: false)
    2. Make instructions clear and numbered
    3. Include time estimates for prep, cooking, and total
    4. Keep measurements simple (cups, tbsp, etc.)
    5. Make the recipe practical for home cooks
    6. ONLY respond with the JSON between the --- markers
    ''';

    final apiKey = 'AIzaSyCj578QUFNzijXPpjRKCEjxeNEpSoQ59R4';
    final model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
    );

    try {
      final response = await model.generateContent([Content.text(prompt)]);
      final rawResponse = response.text ?? '';
      print('Raw API response:\n$rawResponse');

      return _parseRecipeResponse(rawResponse);
    } catch (e) {
      print('Error generating recipe: $e');
      return null;
    }
  }

  static Map<String, dynamic>? _parseRecipeResponse(String rawResponse) {
    try {
      // Improved JSON extraction
      final jsonPattern = RegExp(
        r'---\s*\n({.*?})\s*\n---',
        dotAll: true,
        caseSensitive: false,
      );
      
      final match = jsonPattern.firstMatch(rawResponse);
      if (match == null) {
        print('No JSON found between markers');
        return _fallbackParse(rawResponse);
      }

      final jsonString = match.group(1)?.trim() ?? '';
      if (jsonString.isEmpty) {
        print('Empty JSON content');
        return _fallbackParse(rawResponse);
      }

      // Parse the JSON with error handling
      final parsedJson = jsonDecode(jsonString) as Map<String, dynamic>;
      
      // Validate required fields
      if (parsedJson['name'] == null || 
          parsedJson['ingredients'] == null || 
          parsedJson['instructions'] == null) {
        print('Missing required fields in JSON');
        return _fallbackParse(rawResponse);
      }

      return parsedJson;
    } catch (e) {
      print('Error parsing recipe response: $e');
      return _fallbackParse(rawResponse);
    }
  }

  static Map<String, dynamic>? _fallbackParse(String rawResponse) {
    try {
      final lines = rawResponse.split('\n').where((line) => line.trim().isNotEmpty).toList();
      
      final result = <String, dynamic>{
        'name': 'Generated Recipe',
        'prepTime': 'Not specified',
        'cookTime': 'Not specified',
        'totalTime': 'Not specified',
        'servings': 'Not specified',
        'ingredients': [],
        'instructions': [],
        'notes': ''
      };

      String currentSection = '';
      bool foundIngredients = false;
      bool foundInstructions = false;
      
      for (final line in lines) {
        final trimmedLine = line.trim();
        
        // Extract recipe name
        if (trimmedLine.toLowerCase().startsWith('**recipe name:**')) {
          result['name'] = trimmedLine.substring('**recipe name:**'.length).trim();
        } 
        // Extract times
        else if (trimmedLine.toLowerCase().startsWith('**prep time:**')) {
          result['prepTime'] = trimmedLine.substring('**prep time:**'.length).trim();
        }
        else if (trimmedLine.toLowerCase().startsWith('**cook time:**')) {
          result['cookTime'] = trimmedLine.substring('**cook time:**'.length).trim();
        }
        else if (trimmedLine.toLowerCase().startsWith('**serving size:**') || 
                 trimmedLine.toLowerCase().startsWith('**servings:**')) {
          result['servings'] = trimmedLine.split(':').last.trim();
        }
        // Section detection
        else if (trimmedLine.toLowerCase().contains('ingredient')) {
          currentSection = 'ingredients';
          foundIngredients = true;
        }
        else if (trimmedLine.toLowerCase().contains('instruction')) {
          currentSection = 'instructions';
          foundInstructions = true;
        }
        else if (trimmedLine.toLowerCase().contains('note') || 
                 trimmedLine.toLowerCase().contains('suggestion')) {
          currentSection = 'notes';
        }
        // Content parsing
        else if (currentSection == 'ingredients' && 
                (trimmedLine.startsWith('*') || trimmedLine.startsWith('-'))) {
          (result['ingredients'] as List).add({
            'name': trimmedLine.replaceAll(RegExp(r'^[*\-]\s*'), '').trim(),
            'amount': '',
            'essential': !trimmedLine.toLowerCase().contains('optional')
          });
        }
        else if (currentSection == 'instructions' && 
                RegExp(r'^\d+\.').hasMatch(trimmedLine)) {
          (result['instructions'] as List).add(trimmedLine);
        }
        else if (currentSection == 'notes') {
          result['notes'] += '$trimmedLine\n';
        }
      }

      // If we didn't find structured sections, try to guess
      if (!foundIngredients || !foundInstructions) {
        return _deepFallbackParse(rawResponse);
      }

      return result;
    } catch (e) {
      print('Fallback parsing failed: $e');
      return _deepFallbackParse(rawResponse);
    }
  }

  static Map<String, dynamic> _deepFallbackParse(String rawResponse) {
    // Last resort parsing when everything else fails
    return {
      'name': 'Custom Recipe',
      'prepTime': 'Not specified',
      'cookTime': 'Not specified',
      'totalTime': 'Not specified',
      'servings': 'Not specified',
      'ingredients': ['Mixed ingredients'],
      'instructions': ['Prepare all ingredients', 'Cook as desired'],
      'notes': 'Recipe generated based on your ingredients'
    };
  }
}