import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../widgets/mood_selector_widget.dart';
import '../widgets/activity_card_widget.dart';
import '../widgets/journal_card_widget.dart';
import '../widgets/botanical_painter.dart';
import '../providers/mood_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/app_theme.dart';
import 'profile_dashboard_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
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
          const Positioned.fill(
            child: FloatingBotanicalDots(dotCount: 6),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Top bar ──
                  Row(
                    children: [
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
                  ),
                  const SizedBox(height: 24),

                  // ── Motivational Hero ──
                  Center(
                    child: Column(
                      children: [
                        Text(
                          'Build\nConfidence',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 34,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                            height: 1.15,
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Animated botanical branch illustration
                        const AnimatedBotanicalBranch(size: 200),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                          decoration: BoxDecoration(
                            color: AppTheme.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppTheme.border),
                          ),
                          child: Text(
                            "If we always envy what others have,\nwe'll end up losing what we already\nhave, just like the greedy dog.",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: AppTheme.textSecondary,
                              height: 1.5,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Play button
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: AppTheme.accent,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.accent.withValues(alpha: 0.3),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 28),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 36),

                  // ── Greeting ──
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
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // ── Mood check-in ──
                  _SectionLabel(label: "Today's mood"),
                  const SizedBox(height: 12),
                  MoodSelectorWidget(),
                  const SizedBox(height: 32),

                  // ── Journal ──
                  _SectionLabel(label: 'Reflection'),
                  const SizedBox(height: 12),
                  const JournalCardWidget(
                    prompt: "What is one thing you're grateful for right now?",
                  ),
                  const SizedBox(height: 32),

                  // ── Activities ──
                  _SectionLabel(label: 'Recommended for you'),
                  const SizedBox(height: 12),
                  ActivityCardWidget(
                    title: 'Morning Meditation',
                    duration: '10 min',
                    icon: Icons.self_improvement,
                    onTap: () {
                      context.read<MoodProvider>().saveActivity('meditation');
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Meditation logged ✓')),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  ActivityCardWidget(
                    title: 'Short Walk',
                    duration: '15 min',
                    icon: Icons.directions_walk,
                    onTap: () {
                      context.read<MoodProvider>().saveActivity('walking');
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Walk logged ✓')),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: AppTheme.textMuted,
        letterSpacing: 0.8,
      ),
    );
  }
}
