class GuidedAudioEpisode {
  const GuidedAudioEpisode({
    required this.id,
    required this.title,
    required this.podcastTitle,
    required this.audioUrl,
    required this.durationMinutes,
    required this.description,
    required this.imageUrl,
  });

  final String id;
  final String title;
  final String podcastTitle;
  final String audioUrl;
  final int durationMinutes;
  final String description;
  final String imageUrl;
}
