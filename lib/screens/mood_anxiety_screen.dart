import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_theme.dart';
import '../widgets/breathing_animation_widget.dart';
import '../widgets/journal_card_widget.dart';
import '../widgets/meditation_timer_widget.dart';
import 'cbt_thought_reframer_screen.dart';

class MoodAnxietyScreen extends StatelessWidget {
  const MoodAnxietyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.canvas,
      appBar: AppBar(
        title: const Text('Find Calm'),
        backgroundColor: AppTheme.canvas,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Breathing animation ──
            const Center(child: BreathingAnimationWidget()),
            const SizedBox(height: 32),

            // ── Meditation timer (replaces the old basic timer) ──
            _Label(text: 'Calm-down meditation'),
            const SizedBox(height: 12),
            const MeditationTimerWidget(),
            const SizedBox(height: 32),

            // ── Journal ──
            _Label(text: 'Journal'),
            const SizedBox(height: 12),
            const JournalCardWidget(
              prompt: "What's worrying you right now? Writing it down helps.",
            ),
            const SizedBox(height: 32),

            // ── CBT Reframer ──
            _Label(text: 'Cognitive Behavioral Therapy'),
            const SizedBox(height: 12),
            _CBTReframerCard(),
          ],
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label({required this.text});
  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textMuted, letterSpacing: 0.8),
    );
  }
}

class _CBTReframerCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const CBTThoughtReframerScreen(),
          transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
          transitionDuration: const Duration(milliseconds: 350),
        ),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
        decoration: BoxDecoration(
          color: AppTheme.positiveSoft,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.positive.withValues(alpha: 0.4), width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🌿', style: TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CBT Thought Reframer',
                  style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w700, color: AppTheme.positive, letterSpacing: -0.2),
                ),
                Text(
                  'Gently challenge negative thoughts',
                  style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary),
                ),
              ],
            ),
            const Spacer(),
            Icon(Icons.arrow_forward_ios, size: 14, color: AppTheme.positive),
          ],
        ),
      ),
    );
  }
}
