import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_theme.dart';

/// Reusable inline meditation timer card.
/// Drop into any mood screen below a section label.
class MeditationTimerWidget extends StatefulWidget {
  const MeditationTimerWidget({super.key});

  @override
  State<MeditationTimerWidget> createState() => _MeditationTimerWidgetState();
}

class _MeditationTimerWidgetState extends State<MeditationTimerWidget>
    with TickerProviderStateMixin {
  // States: setup | running | completed
  _TimerPhase _phase = _TimerPhase.setup;
  int _selectedMinutes = 10;
  int _remaining = 0;
  Timer? _timer;

  late AnimationController _ringController;
  late AnimationController _quoteController;
  late Animation<double> _quoteFade;
  late AnimationController _completeController;
  late Animation<double> _completeFade;
  late Animation<double> _completeScale;

  int _quoteIndex = 0;
  static const List<String> _quotes = [
    'Breathe in peace, breathe out tension.',
    'You are exactly where you need to be.',
    'Let thoughts pass like clouds.',
    'This stillness is a gift to yourself.',
    'Inhale calm. Exhale everything else.',
    'The present moment is enough.',
  ];

  @override
  void initState() {
    super.initState();
    _ringController = AnimationController(vsync: this, duration: const Duration(seconds: 1));

    _quoteController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _quoteFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _quoteController, curve: Curves.easeInOut),
    );

    _completeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _completeFade = Tween<double>(begin: 0.0, end: 1.0).animate(_completeController);
    _completeScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _completeController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _ringController.dispose();
    _quoteController.dispose();
    _completeController.dispose();
    super.dispose();
  }

  void _start() {
    final totalSec = _selectedMinutes * 60;
    _remaining = totalSec;
    _quoteIndex = 0;
    setState(() => _phase = _TimerPhase.running);

    _ringController.duration = Duration(seconds: totalSec);
    _ringController.reset();
    _ringController.forward();
    _quoteController.forward();

    _timer = Timer.periodic(const Duration(seconds: 1), _tick);
  }

  void _tick(Timer t) {
    if (!mounted) return;
    setState(() {
      if (_remaining > 0) {
        _remaining--;
        // Cycle quote every 30s
        if (_remaining % 30 == 0 && _remaining > 0) {
          _quoteController.reverse().then((_) {
            if (mounted) {
              setState(() => _quoteIndex = (_quoteIndex + 1) % _quotes.length);
              _quoteController.forward();
            }
          });
        }
      } else {
        t.cancel();
        _phase = _TimerPhase.completed;
        _completeController.forward();
      }
    });
  }

  void _reset() {
    _timer?.cancel();
    _ringController.reset();
    _quoteController.reset();
    _completeController.reset();
    setState(() {
      _phase = _TimerPhase.setup;
      _selectedMinutes = 10;
    });
  }

  String _fmt(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      child: switch (_phase) {
        _TimerPhase.setup => _buildSetup(),
        _TimerPhase.running => _buildRunning(),
        _TimerPhase.completed => _buildCompleted(),
      },
    );
  }

  // ── Setup card ──────────────────────────────────────────────────────────────
  Widget _buildSetup() {
    return Container(
      key: const ValueKey('setup'),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: AppTheme.positiveSoft,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.self_improvement_outlined, color: AppTheme.positive, size: 18),
              ),
              const SizedBox(width: 12),
              Text(
                'Meditation',
                style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
              ),
              const Spacer(),
              Text(
                '$_selectedMinutes min',
                style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Time selector row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _MiniStepBtn(
                icon: Icons.remove,
                onTap: () => setState(() => _selectedMinutes = (_selectedMinutes - 5).clamp(5, 60)),
              ),
              const SizedBox(width: 24),
              Column(
                children: [
                  Text(
                    '$_selectedMinutes',
                    style: GoogleFonts.inter(fontSize: 44, fontWeight: FontWeight.w800, color: AppTheme.textPrimary, letterSpacing: -1.5),
                  ),
                  Text('minutes', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textMuted)),
                ],
              ),
              const SizedBox(width: 24),
              _MiniStepBtn(
                icon: Icons.add,
                onTap: () => setState(() => _selectedMinutes = (_selectedMinutes + 5).clamp(5, 60)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity, height: 46,
            child: ElevatedButton(
              onPressed: _start,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.positive, elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text('Begin meditation', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  // ── Running card ────────────────────────────────────────────────────────────
  Widget _buildRunning() {
    final total = _selectedMinutes * 60;
    final progress = 1.0 - (_remaining / total);

    return Container(
      key: const ValueKey('running'),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.positive.withValues(alpha: 0.4)),
      ),
      child: Column(
        children: [
          // Compact ring
          SizedBox(
            width: 180, height: 180,
            child: CustomPaint(
              painter: _RingPainter(progress: progress, accentColor: AppTheme.positive, trackColor: AppTheme.positiveSoft),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _fmt(_remaining),
                      style: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.w800, color: AppTheme.textPrimary, letterSpacing: -1),
                    ),
                    Text('left', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textMuted)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          FadeTransition(
            opacity: _quoteFade,
            child: Text(
              _quotes[_quoteIndex],
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 13, fontStyle: FontStyle.italic, color: AppTheme.textSecondary, height: 1.5),
            ),
          ),
          const SizedBox(height: 20),
          TextButton.icon(
            onPressed: _reset,
            icon: const Icon(Icons.stop_circle_outlined, size: 16),
            label: const Text('Stop'),
            style: TextButton.styleFrom(foregroundColor: AppTheme.textMuted),
          ),
        ],
      ),
    );
  }

  // ── Completed card ──────────────────────────────────────────────────────────
  Widget _buildCompleted() {
    return ScaleTransition(
      scale: _completeScale,
      child: FadeTransition(
        opacity: _completeFade,
        child: Container(
          key: const ValueKey('completed'),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppTheme.positiveSoft,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.positive.withValues(alpha: 0.4)),
          ),
          child: Column(
            children: [
              const Icon(Icons.check_circle_outline_rounded, color: AppTheme.positive, size: 40),
              const SizedBox(height: 12),
              Text(
                'Session complete ✨',
                style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
              ),
              const SizedBox(height: 6),
              Text(
                'You gave yourself $_selectedMinutes minutes of peace. That matters.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textSecondary, height: 1.5),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _reset,
                child: const Text('Meditate again'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _TimerPhase { setup, running, completed }

// ── Shared mini step button ──────────────────────────────────────────────────
class _MiniStepBtn extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _MiniStepBtn({required this.icon, required this.onTap});

  @override
  State<_MiniStepBtn> createState() => _MiniStepBtnState();
}

class _MiniStepBtnState extends State<_MiniStepBtn> {
  bool _pressed = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) { setState(() => _pressed = false); widget.onTap(); },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: 44, height: 44,
        decoration: BoxDecoration(
          color: _pressed ? AppTheme.positiveSoft : AppTheme.surfaceDim,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _pressed ? AppTheme.positive.withValues(alpha: 0.4) : AppTheme.border),
        ),
        child: Icon(widget.icon, color: _pressed ? AppTheme.positive : AppTheme.textSecondary, size: 20),
      ),
    );
  }
}

// ── Ring painter (shared with activity_timer_sheet) ──────────────────────────
class _RingPainter extends CustomPainter {
  final double progress;
  final Color accentColor;
  final Color trackColor;

  _RingPainter({required this.progress, required this.accentColor, required this.trackColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 12;
    const strokeWidth = 10.0;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius), -pi / 2, 2 * pi, false,
      Paint()..color = trackColor..style = PaintingStyle.stroke..strokeWidth = strokeWidth..strokeCap = StrokeCap.round,
    );
    if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius), -pi / 2, 2 * pi * progress, false,
        Paint()..color = accentColor..style = PaintingStyle.stroke..strokeWidth = strokeWidth..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress;
}
