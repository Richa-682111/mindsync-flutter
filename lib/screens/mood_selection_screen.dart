import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../providers/mood_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/botanical_painter.dart';
import '../widgets/mood_selector_widget.dart';
import '../widgets/journal_card_widget.dart';
import '../widgets/featured_content_card.dart';
import 'profile_dashboard_screen.dart';
import 'meditation_library_screen.dart';
import 'mental_health_resources_screen.dart';
import 'mood_happy_screen.dart';
import 'mood_stressed_screen.dart';
import 'mood_anxiety_screen.dart';

class MoodSelectionScreen extends StatefulWidget {
  const MoodSelectionScreen({super.key});

  @override
  State<MoodSelectionScreen> createState() => _MoodSelectionScreenState();
}

class _MoodSelectionScreenState extends State<MoodSelectionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _staggerCtrl;

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  void initState() {
    super.initState();
    _staggerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
  }

  @override
  void dispose() {
    _staggerCtrl.dispose();
    super.dispose();
  }

  Animation<double> _staggerFade(double begin, double end) {
    return Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _staggerCtrl, curve: Interval(begin, end, curve: Curves.easeOut)),
    );
  }

  Animation<Offset> _staggerSlide(double begin, double end) {
    return Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero).animate(
      CurvedAnimation(parent: _staggerCtrl, curve: Interval(begin, end, curve: Curves.easeOut)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final today = DateFormat('EEEE, MMM d').format(DateTime.now());
    final auth = context.watch<AuthProvider>();
    final email = auth.user?.email ?? '';
    final name = email.contains('@') ? email.split('@').first : 'there';

    return Scaffold(
      backgroundColor: AppTheme.canvas,
      body: Stack(
        children: [
          // Floating botanical dots
          const Positioned.fill(
            child: FloatingBotanicalDots(dotCount: 8),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Top Bar: ME badge + avatar ──
                  _buildTopBar(context),
                  const SizedBox(height: 28),

                  // ── Greeting ──
                  FadeTransition(
                    opacity: _staggerFade(0.0, 0.3),
                    child: SlideTransition(
                      position: _staggerSlide(0.0, 0.3),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            today,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.textMuted,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${_greeting()}, $name',
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ── Daily Reflection ──
                  FadeTransition(
                    opacity: _staggerFade(0.1, 0.4),
                    child: SlideTransition(
                      position: _staggerSlide(0.1, 0.4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Daily Reflection',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textMuted,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'How do you feel about\nyour current emotions?',
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 14),
                          const JournalCardWidget(
                            prompt: "What is one thing you're grateful for right now?",
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ── Daily Mood Log ──
                  FadeTransition(
                    opacity: _staggerFade(0.2, 0.5),
                    child: SlideTransition(
                      position: _staggerSlide(0.2, 0.5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Daily Mood Log',
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 14),
                          MoodSelectorWidget(),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ── Mood-based Navigation ──
                  FadeTransition(
                    opacity: _staggerFade(0.3, 0.6),
                    child: SlideTransition(
                      position: _staggerSlide(0.3, 0.6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'How are you feeling?',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: _MoodNavCard(
                                  emoji: '☺️',
                                  label: 'Happy',
                                  color: AppTheme.moodHappy,
                                  bgColor: AppTheme.positiveSoft,
                                  onTap: () => _selectMood(context, 'Happy'),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _MoodNavCard(
                                  emoji: '😤',
                                  label: 'Stressed',
                                  color: AppTheme.moodStressed,
                                  bgColor: AppTheme.warmSoft,
                                  onTap: () => _selectMood(context, 'Stressed'),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _MoodNavCard(
                                  emoji: '😰',
                                  label: 'Anxious',
                                  color: AppTheme.moodAnxious,
                                  bgColor: AppTheme.cardPeach,
                                  onTap: () => _selectMood(context, 'Anxiety'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 36),

                  // ── Featured ──
                  FadeTransition(
                    opacity: _staggerFade(0.4, 0.7),
                    child: SlideTransition(
                      position: _staggerSlide(0.4, 0.7),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Featured',
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 14),
                          FeaturedContentCard(
                            title: 'Build Confidence',
                            subtitle: 'Mindfulness & self-growth',
                            icon: Icons.eco_outlined,
                            bgColor: AppTheme.cardSage,
                            iconColor: AppTheme.accent,
                            onTap: () => _selectMood(context, 'Happy'),
                          ),
                          const SizedBox(height: 10),
                          FeaturedContentCard(
                            title: 'Manage Anxiety',
                            subtitle: 'Breathing & calm exercises',
                            icon: Icons.spa_outlined,
                            bgColor: AppTheme.cardPink,
                            iconColor: AppTheme.moodLove,
                            onTap: () => _selectMood(context, 'Anxiety'),
                          ),
                          const SizedBox(height: 10),
                          FeaturedContentCard(
                            title: 'Stress Relief',
                            subtitle: 'Release tension & relax',
                            icon: Icons.self_improvement_outlined,
                            bgColor: AppTheme.cardPeach,
                            iconColor: AppTheme.warmTone,
                            onTap: () => _selectMood(context, 'Stressed'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // ── Quick links ──
                  FadeTransition(
                    opacity: _staggerFade(0.5, 0.8),
                    child: SlideTransition(
                      position: _staggerSlide(0.5, 0.8),
                      child: Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          OutlinedButton.icon(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const MeditationLibraryScreen(),
                              ),
                            ),
                            icon: const Icon(Icons.self_improvement_outlined, size: 16),
                            label: const Text('Meditation Library'),
                          ),
                          OutlinedButton.icon(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const MentalHealthResourcesScreen(),
                              ),
                            ),
                            icon: const Icon(Icons.health_and_safety_outlined, size: 16),
                            label: const Text('Help & Resources'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Row(
      children: [
        // ME badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.accent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            'ME',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 1,
            ),
          ),
        ),
        const Spacer(),
        // Avatar
        GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProfileDashboardScreen()),
          ),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.accentSoft,
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.accent.withValues(alpha: 0.3), width: 2),
            ),
            child: const Icon(Icons.person_outline, color: AppTheme.accent, size: 20),
          ),
        ),
      ],
    );
  }

  void _selectMood(BuildContext context, String mood) {
    final moodProvider = Provider.of<MoodProvider>(context, listen: false);
    moodProvider.saveMood(mood);

    Widget nextScreen;
    if (mood == 'Happy') {
      nextScreen = const MoodHappyScreen();
    } else if (mood == 'Stressed') {
      nextScreen = const MoodStressedScreen();
    } else {
      nextScreen = const MoodAnxietyScreen();
    }

    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => nextScreen,
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 250),
      ),
    );
  }
}

/// Small mood navigation card with press animation.
class _MoodNavCard extends StatefulWidget {
  final String emoji;
  final String label;
  final Color color;
  final Color bgColor;
  final VoidCallback onTap;

  const _MoodNavCard({
    required this.emoji,
    required this.label,
    required this.color,
    required this.bgColor,
    required this.onTap,
  });

  @override
  State<_MoodNavCard> createState() => _MoodNavCardState();
}

class _MoodNavCardState extends State<_MoodNavCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) { setState(() => _pressed = false); widget.onTap(); },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.93 : 1.0,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            color: widget.bgColor,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            children: [
              Text(widget.emoji, style: const TextStyle(fontSize: 32)),
              const SizedBox(height: 8),
              Text(
                widget.label,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: widget.color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
