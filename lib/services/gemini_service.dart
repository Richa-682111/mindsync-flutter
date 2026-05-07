import 'package:google_generative_ai/google_generative_ai.dart';

class ThoughtAnalysis {
  const ThoughtAnalysis({
    required this.category,
    required this.reframedThought,
  });

  final String category;
  final String reframedThought;
}

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

  static Future<ThoughtAnalysis?> analyzeThought({
    required String thought,
  }) async {
    final model = _model;
    if (model == null) return null;

    final prompt = '''
You are a warm CBT companion.
Analyze this thought and return a supportive reframe:
"$thought"

Return strictly in this format:
CATEGORY: <one short category>
REFRAME: <one positive, realistic 1-2 sentence reframe>

No extra text.
''';

    final response = await model.generateContent([Content.text(prompt)]);
    final text = response.text?.trim();
    if (text == null || text.isEmpty) return null;

    final lines = text.split('\n');
    String category = 'Negative Thought Pattern';
    String reframe = '';

    for (final raw in lines) {
      final line = raw.trim();
      if (line.toUpperCase().startsWith('CATEGORY:')) {
        category = line.substring('CATEGORY:'.length).trim();
      } else if (line.toUpperCase().startsWith('REFRAME:')) {
        reframe = line.substring('REFRAME:'.length).trim();
      }
    }

    if (reframe.isEmpty) {
      reframe = text.replaceAll('\n', ' ').trim();
    }

    return ThoughtAnalysis(
      category: category.isEmpty ? 'Negative Thought Pattern' : category,
      reframedThought: reframe,
    );
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

  static Future<List<String>?> generateDailyGoals({
    required String mood,
  }) async {
    final model = _model;
    if (model == null) return null;

    final prompt = '''
Generate exactly 4 practical daily goals for someone feeling "$mood".
Rules:
- Each goal must be short and actionable (4-9 words)
- Keep goals gentle and realistic
- Return one goal per line with no numbering
''';

    final response = await model.generateContent([Content.text(prompt)]);
    final text = response.text?.trim();
    if (text == null || text.isEmpty) return null;

    final goals = text
        .split('\n')
        .map((line) => line.replaceFirst(RegExp(r'^[\-\d\.\)\s]+'), '').trim())
        .where((line) => line.isNotEmpty)
        .take(4)
        .toList();

    if (goals.isEmpty) return null;
    return goals;
  }
}
