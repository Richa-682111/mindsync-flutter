import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_theme.dart';

// ─── Entry point ───────────────────────────────────────────────────────────────
class ActivityTimerSheet {
  static void show(BuildContext context, {required String activityName, required Color accentColor}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _TimerSetupSheet(activityName: activityName, accentColor: accentColor),
    );
  }
}

// ─── Phase 1: Time selection sheet ────────────────────────────────────────────
class _TimerSetupSheet extends StatefulWidget {
  final String activityName;
  final Color accentColor;
  const _TimerSetupSheet({required this.activityName, required this.accentColor});

  @override
  State<_TimerSetupSheet> createState() => _TimerSetupSheetState();
}

class _TimerSetupSheetState extends State<_TimerSetupSheet> {
  int _minutes = 10;

  void _increment() => setState(() => _minutes = (_minutes + 5).clamp(5, 60));
  void _decrement() => setState(() => _minutes = (_minutes - 5).clamp(5, 60));

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 28, right: 28, top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 36,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 36, height: 4,
            decoration: BoxDecoration(
              color: AppTheme.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          // Activity icon + name
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
              color: widget.accentColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(_activityIcon(widget.activityName), color: widget.accentColor, size: 26),
          ),
          const SizedBox(height: 12),
          Text(
            widget.activityName,
            style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary, letterSpacing: -0.3),
          ),
          const SizedBox(height: 4),
          Text(
            'How long would you like to go?',
            style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textMuted),
          ),
          const SizedBox(height: 32),
          // Time picker row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _StepButton(icon: Icons.remove, onTap: _decrement, color: widget.accentColor),
              const SizedBox(width: 28),
              Column(
                children: [
                  Text(
                    '$_minutes',
                    style: GoogleFonts.inter(fontSize: 52, fontWeight: FontWeight.w800, color: AppTheme.textPrimary, letterSpacing: -2),
                  ),
                  Text(
                    'minutes',
                    style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textMuted, letterSpacing: 0.3),
                  ),
                ],
              ),
              const SizedBox(width: 28),
              _StepButton(icon: Icons.add, onTap: _increment, color: widget.accentColor),
            ],
          ),
          const SizedBox(height: 36),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _launchTimer(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.accentColor,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: Text(
                'Start $_minutes min session',
                style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _launchTimer(BuildContext context) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => ActivityTimerScreen(
          activityName: widget.activityName,
          totalSeconds: _minutes * 60,
          accentColor: widget.accentColor,
        ),
        transitionsBuilder: (_, animation, __, child) => FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }

  IconData _activityIcon(String name) {
    if (name.toLowerCase().contains('walk')) return Icons.directions_walk_outlined;
    if (name.toLowerCase().contains('stretch') || name.toLowerCase().contains('move')) return Icons.accessibility_new_outlined;
    if (name.toLowerCase().contains('meditat')) return Icons.self_improvement_outlined;
    return Icons.timer_outlined;
  }
}

class _StepButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color color;
  const _StepButton({required this.icon, required this.onTap, required this.color});

  @override
  State<_StepButton> createState() => _StepButtonState();
}

class _StepButtonState extends State<_StepButton> {
  bool _pressed = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) { setState(() => _pressed = false); widget.onTap(); },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        width: 52, height: 52,
        decoration: BoxDecoration(
          color: _pressed ? widget.color.withValues(alpha: 0.15) : AppTheme.surfaceDim,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _pressed ? widget.color.withValues(alpha: 0.4) : AppTheme.border),
        ),
        child: Icon(widget.icon, color: _pressed ? widget.color : AppTheme.textSecondary, size: 22),
      ),
    );
  }
}

// ─── Phase 2: Full-screen circular timer ──────────────────────────────────────
class ActivityTimerScreen extends StatefulWidget {
  final String activityName;
  final int totalSeconds;
  final Color accentColor;

  const ActivityTimerScreen({
    super.key,
    required this.activityName,
    required this.totalSeconds,
    required this.accentColor,
  });

  @override
  State<ActivityTimerScreen> createState() => _ActivityTimerScreenState();
}

class _ActivityTimerScreenState extends State<ActivityTimerScreen>
    with TickerProviderStateMixin {
  late int _remaining;
  Timer? _timer;
  late AnimationController _ringController;
  late AnimationController _quoteController;
  late Animation<double> _quoteFade;
  bool _completed = false;
  int _quoteIndex = 0;

  static const List<String> _quotes = [
    'Keep going, you can do it!',
    'Every step forward matters.',
    'You are stronger than you think.',
    'Breathe and keep moving.',
    'Progress, not perfection.',
    'You are doing amazing!',
    'This moment is building you.',
    'Almost there — stay with it!',
  ];

  @override
  void initState() {
    super.initState();
    _remaining = widget.totalSeconds;

    _ringController = AnimationController(vsync: this, duration: Duration(seconds: widget.totalSeconds));
    _ringController.forward();

    _quoteController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _quoteFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _quoteController, curve: Curves.easeOut),
    );
    _quoteController.forward();

    _timer = Timer.periodic(const Duration(seconds: 1), _tick);
  }

  void _tick(Timer t) {
    if (!mounted) return;
    setState(() {
      if (_remaining > 0) {
        _remaining--;
        // Rotate quote every 30s
        final newIndex = (_quoteIndex + 1) % _quotes.length;
        if (_remaining % 30 == 0 && _remaining != widget.totalSeconds) {
          _quoteController.reverse().then((_) {
            if (mounted) {
              setState(() => _quoteIndex = newIndex);
              _quoteController.forward();
            }
          });
        }
      } else {
        t.cancel();
        _completed = true;
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _ringController.dispose();
    _quoteController.dispose();
    super.dispose();
  }

  String _formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    if (_completed) return _CompletionScreen(activityName: widget.activityName, accentColor: widget.accentColor);

    final progress = 1.0 - (_remaining / widget.totalSeconds);

    return Scaffold(
      backgroundColor: AppTheme.canvas,
      appBar: AppBar(
        backgroundColor: AppTheme.canvas,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(widget.activityName, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppTheme.textSecondary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // ── Circular ring timer ──
              SizedBox(
                width: 260,
                height: 260,
                child: AnimatedBuilder(
                  animation: _ringController,
                  builder: (_, __) => CustomPaint(
                    painter: _RingPainter(
                      progress: progress,
                      accentColor: widget.accentColor,
                      trackColor: widget.accentColor.withValues(alpha: 0.1),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _formatTime(_remaining),
                            style: GoogleFonts.inter(
                              fontSize: 48,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textPrimary,
                              letterSpacing: -2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'remaining',
                            style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textMuted),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 48),
              // ── Motivational quote ──
              FadeTransition(
                opacity: _quoteFade,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: widget.accentColor.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: widget.accentColor.withValues(alpha: 0.2)),
                  ),
                  child: Text(
                    _quotes[_quoteIndex],
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontStyle: FontStyle.italic,
                      color: AppTheme.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              // ── Stop button ──
              TextButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.stop_circle_outlined, size: 18),
                label: const Text('Stop session'),
                style: TextButton.styleFrom(foregroundColor: AppTheme.textMuted),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Circular ring painter ─────────────────────────────────────────────────────
class _RingPainter extends CustomPainter {
  final double progress;
  final Color accentColor;
  final Color trackColor;

  _RingPainter({required this.progress, required this.accentColor, required this.trackColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 16;
    const strokeWidth = 12.0;

    // Track
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2, 2 * pi, false,
      Paint()
        ..color = trackColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );

    // Progress arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2, 2 * pi * progress, false,
      Paint()
        ..color = accentColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress;
}

// ─── Completion screen ────────────────────────────────────────────────────────
class _CompletionScreen extends StatefulWidget {
  final String activityName;
  final Color accentColor;
  const _CompletionScreen({required this.activityName, required this.accentColor});

  @override
  State<_CompletionScreen> createState() => _CompletionScreenState();
}

class _CompletionScreenState extends State<_CompletionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _scale = Tween<double>(begin: 0.7, end: 1.0).animate(CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut));
    _fade = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _ctrl.forward();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.canvas,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fade,
          child: ScaleTransition(
            scale: _scale,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 80, height: 80,
                      decoration: BoxDecoration(
                        color: widget.accentColor.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.check_rounded, color: widget.accentColor, size: 40),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Well done!',
                      style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w800, color: AppTheme.textPrimary, letterSpacing: -0.5),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'You completed your ${widget.activityName.toLowerCase()} session.\nTake a moment to appreciate yourself.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(fontSize: 15, color: AppTheme.textSecondary, height: 1.6),
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity, height: 52,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: widget.accentColor, elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: Text('Continue', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
