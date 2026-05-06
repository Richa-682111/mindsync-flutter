import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../widgets/mood_selector_widget.dart';
import '../widgets/activity_card_widget.dart';
import '../widgets/journal_card_widget.dart';
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
      appBar: AppBar(
        backgroundColor: AppTheme.canvas,
        elevation: 0,
        scrolledUnderElevation: 0,
        // No title — greeting is in the body
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileDashboardScreen()),
              ),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppTheme.accentSoft,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.person_outline, color: AppTheme.accent, size: 20),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
              style: GoogleFonts.inter(
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
