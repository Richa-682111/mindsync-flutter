import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/guided_audio_episode.dart';

class GuidedMeditationApiService {
  GuidedMeditationApiService._();

  static const String _apiKey = String.fromEnvironment('LISTEN_NOTES_API_KEY');
  static const String _baseUrl = 'https://listen-api.listennotes.com/api/v2';

  static bool get isConfigured => _apiKey.isNotEmpty;

  static Future<List<GuidedAudioEpisode>> fetchGuidedMeditations() async {
    if (!isConfigured) return const [];

    final uri = Uri.parse(
      '$_baseUrl/search?q=guided%20meditation%20mindfulness&type=episode&offset=0&len_min=5&len_max=25&language=English&safe_mode=1',
    );

    final response = await http.get(
      uri,
      headers: {'X-ListenAPI-Key': _apiKey},
    );

    if (response.statusCode != 200) {
      return const [];
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final results = (decoded['results'] as List<dynamic>? ?? const []);

    return results
        .map((item) => item as Map<String, dynamic>)
        .where((item) => (item['audio'] ?? '').toString().isNotEmpty)
        .take(10)
        .map(
          (item) => GuidedAudioEpisode(
            id: (item['id'] ?? '').toString(),
            title: (item['title_original'] ?? 'Guided Meditation').toString(),
            podcastTitle: (item['podcast_title_original'] ?? 'Podcast').toString(),
            audioUrl: (item['audio'] ?? '').toString(),
            durationMinutes: (((item['audio_length_sec'] ?? 0) as num) / 60).round(),
            description: (item['description_original'] ?? '').toString(),
            imageUrl: (item['image'] ?? '').toString(),
          ),
        )
        .toList();
  }
}
