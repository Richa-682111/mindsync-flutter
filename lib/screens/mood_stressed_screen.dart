import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_theme.dart';
import '../widgets/journal_card_widget.dart';
import '../widgets/activity_timer_sheet.dart';
import '../widgets/meditation_timer_widget.dart';
import '../widgets/botanical_painter.dart';
import 'release_now_screen.dart';

class MoodStressedScreen extends StatelessWidget {
  const MoodStressedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Feeling Stressed',
          style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.w700),
        ),
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: Stack(
        children: [
          Container(color: AppTheme.canvas),
          const Positioned.fill(child: FloatingBotanicalDots(dotCount: 6)),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Quote banner ──
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppTheme.warmSoft,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.warmTone.withValues(alpha: 0.25)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 42, height: 42,
                          decoration: BoxDecoration(
                            color: AppTheme.warmTone.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.spa_outlined, color: AppTheme.warmTone, size: 22),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          '"Tension is who you think you should be.\nRelaxation is who you are."',
                          style: GoogleFonts.inter(
                            fontSize: 15, fontStyle: FontStyle.italic,
                            color: AppTheme.textPrimary, height: 1.55, letterSpacing: -0.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ── Journal ──
                  _Label(text: 'Reflect'),
                  const SizedBox(height: 12),
                  const JournalCardWidget(
                    prompt: 'What is the main source of your stress right now?',
                  ),
                  const SizedBox(height: 32),

                  // ── Quick relief activities ──
                  _Label(text: 'Quick relief'),
                  const SizedBox(height: 12),
                  _TimedActivityCard(
                    title: 'Go for a Walk',
                    defaultDuration: '15 min',
                    icon: Icons.directions_walk_outlined,
                    accentColor: AppTheme.positive,
                    onTap: () => ActivityTimerSheet.show(
                      context,
                      activityName: 'Go for a Walk',
                      accentColor: AppTheme.positive,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _TimedActivityCard(
                    title: 'Stretch & Move',
                    defaultDuration: '5 min',
                    icon: Icons.accessibility_new_outlined,
                    accentColor: AppTheme.warmTone,
                    onTap: () => ActivityTimerSheet.show(
                      context,
                      activityName: 'Stretch & Move',
                      accentColor: AppTheme.warmTone,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _TimedActivityCard(
                    title: 'Listen to Nature',
                    defaultDuration: '10 min',
                    icon: Icons.headphones_outlined,
                    accentColor: AppTheme.moodAnxious,
                    onTap: () => ActivityTimerSheet.show(
                      context,
                      activityName: 'Listen to Nature',
                      accentColor: AppTheme.moodAnxious,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ── Meditation timer ──
                  _Label(text: 'Meditation'),
                  const SizedBox(height: 12),
                  const MeditationTimerWidget(),
                  const SizedBox(height: 40),

                  // ── Release Now ──
                  _ReleaseNowButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Activity card with timer badge ───────────────────────────────────────────
class _TimedActivityCard extends StatefulWidget {
  final String title;
  final String defaultDuration;
  final IconData icon;
  final Color accentColor;
  final VoidCallback onTap;

  const _TimedActivityCard({
    required this.title,
    required this.defaultDuration,
    required this.icon,
    required this.accentColor,
    required this.onTap,
  });

  @override
  State<_TimedActivityCard> createState() => _TimedActivityCardState();
}

class _TimedActivityCardState extends State<_TimedActivityCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) { setState(() => _pressed = false); widget.onTap(); },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: _pressed ? widget.accentColor.withValues(alpha: 0.06) : AppTheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _pressed ? widget.accentColor.withValues(alpha: 0.3) : AppTheme.border,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 42, height: 42,
                decoration: BoxDecoration(
                  color: widget.accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(widget.icon, color: widget.accentColor, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.title, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                    const SizedBox(height: 2),
                    Text(widget.defaultDuration, style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textMuted)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: widget.accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.timer_outlined, size: 13, color: widget.accentColor),
                    const SizedBox(width: 4),
                    Text('Set timer', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: widget.accentColor)),
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

// ─── Release Now button ────────────────────────────────────────────────────────
class _ReleaseNowButton extends StatefulWidget {
  @override
  State<_ReleaseNowButton> createState() => _ReleaseNowButtonState();
}

class _ReleaseNowButtonState extends State<_ReleaseNowButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800))..repeat(reverse: true);
    _pulse = Tween<double>(begin: 1.0, end: 1.03).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() { _pulseCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulse,
      builder: (_, child) => Transform.scale(scale: _pulse.value, child: child),
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const ReleaseNowScreen(),
            transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
            transitionDuration: const Duration(milliseconds: 350),
          ),
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
          decoration: BoxDecoration(
            color: AppTheme.warmSoft,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.warmTone.withValues(alpha: 0.35), width: 1.5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🔥', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Release Now',
                    style: GoogleFonts.playfairDisplay(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.warmTone),
                  ),
                  Text(
                    'Write it down and let it burn away',
                    style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary),
                  ),
                ],
              ),
              const Spacer(),
              Icon(Icons.arrow_forward_ios, size: 14, color: AppTheme.warmTone),
            ],
          ),
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
