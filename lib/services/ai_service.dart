import 'dart:convert';
import 'package:http/http.dart' as http;

class ThoughtAnalysis {
  const ThoughtAnalysis({
    required this.category,
    required this.reframedThought,
  });

  final String category;
  final String reframedThought;
}

class AiService {
  AiService._();

  static const String _apiKey = String.fromEnvironment('OPENROUTER_API_KEY');
  static const String _modelName = String.fromEnvironment(
    'OPENROUTER_MODEL',
    defaultValue: 'google/gemini-2.5-flash',
  );

  static bool get isConfigured => _apiKey.isNotEmpty;

  static Future<String?> _generateContent(String prompt) async {
    if (!isConfigured) return null;

    try {
      final response = await http.post(
        Uri.parse('https://openrouter.ai/api/v1/chat/completions'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
          'HTTP-Referer': 'https://github.com/mindsync/mindsync',
          'X-Title': 'MindSync',
        },
        body: jsonEncode({
          'model': _modelName,
          'messages': [
            {'role': 'user', 'content': prompt}
          ],
          'temperature': 0.6,
          'max_tokens': 350,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['choices'] != null && data['choices'].isNotEmpty) {
          return data['choices'][0]['message']['content'];
        }
      }
      return null;
    } catch (e) {
      print('OpenRouter API Error: $e');
      return null;
    }
  }

  static Future<String?> generateReframedThought({
    required String thought,
    required String distortionType,
  }) async {
    final prompt = '''
You are a warm CBT companion.
The user entered this negative thought: "$thought"
Detected cognitive distortion: "$distortionType"

Return only one short supportive reframe in 1-2 sentences.
Tone: calm, hopeful, practical.
Avoid clinical jargon, avoid disclaimers.
''';

    final text = await _generateContent(prompt);
    if (text == null || text.trim().isEmpty) return null;
    return text.trim();
  }

  static Future<ThoughtAnalysis?> analyzeThought({
    required String thought,
  }) async {
    final prompt = '''
You are a warm CBT companion.
Analyze this thought and return a supportive reframe:
"$thought"

Return strictly in this format:
CATEGORY: <one short category>
REFRAME: <one positive, realistic 1-2 sentence reframe>

No extra text.
''';

    final text = await _generateContent(prompt);
    if (text == null || text.trim().isEmpty) return null;

    final lines = text.trim().split('\n');
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
    final prompt = '''
Create one reflective journaling prompt for someone feeling "$mood".
Requirements:
- One sentence only
- Gentle, practical, and uplifting
- Encourage self-awareness and emotional release
- Max 22 words
Return only the prompt text.
''';

    final text = await _generateContent(prompt);
    if (text == null || text.trim().isEmpty) return null;
    return text.replaceAll('\n', ' ').trim();
  }

  static Future<List<String>?> generateMoodBoosterTips({
    required String mood,
  }) async {
    final prompt = '''
Generate exactly 5 actionable mood-booster tips for someone feeling "$mood".
Each tip must be short (8-14 words) and concrete.
Return plain text with one tip per line. No numbering, no heading.
''';

    final text = await _generateContent(prompt);
    if (text == null || text.trim().isEmpty) return null;

    final lines = text
        .split('\n')
        .map((line) => line.replaceFirst(RegExp(r'^[\-\d\.\)\s\*]+'), '').trim())
        .where((line) => line.isNotEmpty)
        .take(5)
        .toList();

    if (lines.isEmpty) return null;
    return lines;
  }

  static Future<List<String>?> generateDailyGoals({
    required String mood,
  }) async {
    final prompt = '''
Generate exactly 4 practical daily goals for someone feeling "$mood".
Rules:
- Each goal must be short and actionable (4-9 words)
- Keep goals gentle and realistic
- Return one goal per line with no numbering
''';

    final text = await _generateContent(prompt);
    if (text == null || text.trim().isEmpty) return null;

    final goals = text
        .split('\n')
        .map((line) => line.replaceFirst(RegExp(r'^[\-\d\.\)\s\*]+'), '').trim())
        .where((line) => line.isNotEmpty)
        .take(4)
        .toList();

    if (goals.isEmpty) return null;
    return goals;
  }
}
