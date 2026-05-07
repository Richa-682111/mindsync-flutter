class MeditationSession {
  const MeditationSession({
    required this.id,
    required this.title,
    required this.theme,
    required this.durationMinutes,
    required this.summary,
    required this.script,
  });

  final String id;
  final String title;
  final String theme;
  final int durationMinutes;
  final String summary;
  final List<String> script;
}
