import 'package:google_generative_ai/google_generative_ai.dart';

void fetchGeminiResponse() async {
  // Replace with your API key
  final apiKey = 'AIzaSyCj578QUFNzijXPpjRKCEjxeNEpSoQ59R4';
  final model = GenerativeModel(
    model: 'gemini-2.0-flash',  // Text-only model
    apiKey: apiKey,
  );

  try {
    final response = await model.generateContent([Content.text('Generate a recipie using apples, cabage and mayonase.')]);
    print(response.text);  // Output: Gemini's response
  } catch (e) {
    print('Error: $e');
  }
}