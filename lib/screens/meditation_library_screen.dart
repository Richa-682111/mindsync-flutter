import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data/meditation_sessions.dart';
import '../models/guided_audio_episode.dart';
import '../models/meditation_session.dart';
import '../services/guided_meditation_api_service.dart';
import '../utils/app_theme.dart';

class MeditationLibraryScreen extends StatefulWidget {
  const MeditationLibraryScreen({super.key});

  @override
  State<MeditationLibraryScreen> createState() => _MeditationLibraryScreenState();
}

class _MeditationLibraryScreenState extends State<MeditationLibraryScreen> {
  String _selectedTheme = 'all';
  int _selectedAudioDuration = 5;

  static const List<String> _themes = ['all', 'stress', 'anxiety', 'sleep', 'focus'];
  static const List<GuidedAudioEpisode> _curatedEpisodes = [
    GuidedAudioEpisode(id: 'c1', title: '5 Minute Meditation You Can Do Anywhere', podcastTitle: 'Goodful', audioUrl: 'https://www.youtube.com/watch?v=inpok4MKVLM', durationMinutes: 5, description: 'Quick guided reset.', imageUrl: ''),
    GuidedAudioEpisode(id: 'c2', title: '5 Minute Mindfulness Meditation', podcastTitle: 'The Honest Guys', audioUrl: 'https://www.youtube.com/watch?v=ssss7V1_eyA', durationMinutes: 5, description: 'Short mindfulness practice.', imageUrl: ''),
    GuidedAudioEpisode(id: 'c3', title: '10 Minute Guided Meditation for Anxiety', podcastTitle: 'Great Meditation', audioUrl: 'https://www.youtube.com/watch?v=O-6f5wQXSu8', durationMinutes: 10, description: 'Calming session for anxiety.', imageUrl: ''),
    GuidedAudioEpisode(id: 'c4', title: '10 Minute Morning Meditation', podcastTitle: 'Great Meditation', audioUrl: 'https://www.youtube.com/watch?v=ZToicYcHIOU', durationMinutes: 10, description: 'Morning reset.', imageUrl: ''),
    GuidedAudioEpisode(id: 'c5', title: '20 Minute Deep Relaxation Meditation', podcastTitle: 'The Mindful Movement', audioUrl: 'https://www.youtube.com/watch?v=U6Ay9v7gK9w', durationMinutes: 20, description: 'Long-form relaxation.', imageUrl: ''),
    GuidedAudioEpisode(id: 'c6', title: 'Sleep Meditation: Let Go of Overthinking', podcastTitle: 'Jason Stephenson', audioUrl: 'https://www.youtube.com/watch?v=aEqlQvczMJQ', durationMinutes: 20, description: 'Sleep wind-down.', imageUrl: ''),
  ];

  @override
  Widget build(BuildContext context) {
    final sessions = MeditationSessionsData.sessions.where((s) {
      return _selectedTheme == 'all' || s.theme == _selectedTheme;
    }).toList();

    return Scaffold(
      backgroundColor: AppTheme.canvas,
      appBar: AppBar(
        title: Text('Meditation Library', style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.w700)),
        backgroundColor: AppTheme.canvas,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _themes.map((theme) {
                    final selected = theme == _selectedTheme;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedTheme = theme),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: selected ? AppTheme.accent : AppTheme.surfaceDim,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: selected ? AppTheme.accent : AppTheme.border),
                          ),
                          child: Text(
                            theme.toUpperCase(),
                            style: GoogleFonts.inter(
                              color: selected ? Colors.white : AppTheme.textSecondary,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  children: [
                    ...sessions.map(
                      (session) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _MeditationCard(
                          session: session,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MeditationSessionDetailScreen(session: session),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Online Guided Audio',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [5, 10, 20].map((minutes) {
                        final selected = minutes == _selectedAudioDuration;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedAudioDuration = minutes),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: selected ? AppTheme.accent : AppTheme.surfaceDim,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: selected ? AppTheme.accent : AppTheme.border),
                            ),
                            child: Text(
                              '$minutes min',
                              style: GoogleFonts.inter(
                                color: selected ? Colors.white : AppTheme.textSecondary,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 10),
                    FutureBuilder<List<GuidedAudioEpisode>>(
                      future: GuidedMeditationApiService.isConfigured
                          ? GuidedMeditationApiService.fetchGuidedMeditations()
                          : Future.value(_curatedEpisodes),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              child: CircularProgressIndicator(strokeWidth: 2.2, color: AppTheme.accent),
                            ),
                          );
                        }

                        final source = snapshot.data ?? _curatedEpisodes;
                        final filtered = source.where((e) {
                          if (_selectedAudioDuration == 5) return e.durationMinutes <= 7;
                          if (_selectedAudioDuration == 10) return e.durationMinutes >= 8 && e.durationMinutes <= 14;
                          return e.durationMinutes >= 15;
                        }).toList();

                        if (filtered.isEmpty) {
                          return Text(
                            'No $_selectedAudioDuration min sessions right now.',
                            style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textMuted),
                          );
                        }

                        return Column(
                          children: filtered.map((e) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: _AudioEpisodeCard(episode: e),
                          )).toList(),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AudioEpisodeCard extends StatelessWidget {
  const _AudioEpisodeCard({required this.episode});
  final GuidedAudioEpisode episode;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(episode.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
          const SizedBox(height: 4),
          Text('${episode.podcastTitle} • ${episode.durationMinutes} min', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textMuted)),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton.icon(
              onPressed: () async {
                final uri = Uri.parse(episode.audioUrl);
                final opened = await launchUrl(uri, mode: LaunchMode.platformDefault);
                if (!opened && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open this link.')));
                }
              },
              icon: const Icon(Icons.play_arrow_rounded, size: 16),
              label: const Text('Play Audio'),
            ),
          ),
        ],
      ),
    );
  }
}

class _MeditationCard extends StatefulWidget {
  const _MeditationCard({required this.session, required this.onTap});
  final MeditationSession session;
  final VoidCallback onTap;

  @override
  State<_MeditationCard> createState() => _MeditationCardState();
}

class _MeditationCardState extends State<_MeditationCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) { setState(() => _pressed = false); widget.onTap(); },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _pressed ? AppTheme.accentSoft : AppTheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _pressed ? AppTheme.accent.withValues(alpha: 0.3) : AppTheme.border),
          ),
          child: Row(
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(color: AppTheme.accentSoft, borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.self_improvement_outlined, size: 18, color: AppTheme.accent),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.session.title, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                    const SizedBox(height: 2),
                    Text('${widget.session.durationMinutes} min - ${widget.session.theme}', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textMuted)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppTheme.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}

class MeditationSessionDetailScreen extends StatelessWidget {
  const MeditationSessionDetailScreen({super.key, required this.session});
  final MeditationSession session;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.canvas,
      appBar: AppBar(
        title: Text(session.title, style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.w700, fontSize: 18)),
        backgroundColor: AppTheme.canvas,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(session.summary, style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textSecondary, height: 1.5)),
              const SizedBox(height: 16),
              ...session.script.asMap().entries.map((e) {
                final idx = e.key + 1;
                final text = e.value;
                return Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Text('$idx. $text', style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textPrimary, height: 1.4)),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
