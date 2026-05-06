import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  GeminiService._();

  static const String _apiKey = String.fromEnvironment('GEMINI_API_KEY');
  static const String _modelName = String.fromEnvironment(
    'GEMINI_MODEL',
    defaultValue: 'gemini-1.5-flash',
  );

  static bool get isConfigured => _apiKey.isNotEmpty;

  static GenerativeModel? get _model {
    if (!isConfigured) return null;
    return GenerativeModel(
      model: _modelName,
      apiKey: _apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.6,
        maxOutputTokens: 350,
      ),
    );
  }

  static Future<String?> generateReframedThought({
    required String thought,
    required String distortionType,
  }) async {
    final model = _model;
    if (model == null) return null;

    final prompt = '''
You are a warm CBT companion.
The user entered this negative thought: "$thought"
Detected cognitive distortion: "$distortionType"

Return only one short supportive reframe in 1-2 sentences.
Tone: calm, hopeful, practical.
Avoid clinical jargon, avoid disclaimers.
''';

    final response = await model.generateContent([Content.text(prompt)]);
    final text = response.text?.trim();
    if (text == null || text.isEmpty) return null;
    return text;
  }

  static Future<String?> generateJournalPrompt({required String mood}) async {
    final model = _model;
    if (model == null) return null;

    final prompt = '''
Create one reflective journaling prompt for someone feeling "$mood".
Requirements:
- One sentence only
- Gentle, practical, and uplifting
- Encourage self-awareness and emotional release
- Max 22 words
Return only the prompt text.
''';

    final response = await model.generateContent([Content.text(prompt)]);
    final text = response.text?.trim();
    if (text == null || text.isEmpty) return null;
    return text.replaceAll('\n', ' ');
  }

  static Future<List<String>?> generateMoodBoosterTips({
    required String mood,
  }) async {
    final model = _model;
    if (model == null) return null;

    final prompt = '''
Generate exactly 5 actionable mood-booster tips for someone feeling "$mood".
Each tip must be short (8-14 words) and concrete.
Return plain text with one tip per line. No numbering, no heading.
''';

    final response = await model.generateContent([Content.text(prompt)]);
    final text = response.text?.trim();
    if (text == null || text.isEmpty) return null;

    final lines = text
        .split('\n')
        .map((line) => line.replaceFirst(RegExp(r'^[\-\d\.\)\s]+'), '').trim())
        .where((line) => line.isNotEmpty)
        .take(5)
        .toList();

    if (lines.isEmpty) return null;
    return lines;
  }
}
