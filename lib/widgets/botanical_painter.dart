import 'dart:math';
import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

/// Floating botanical dots background decoration.
class FloatingBotanicalDots extends StatefulWidget {
  final int dotCount;
  final Widget? child;

  const FloatingBotanicalDots({super.key, this.dotCount = 12, this.child});

  @override
  State<FloatingBotanicalDots> createState() => _FloatingBotanicalDotsState();
}

class _FloatingBotanicalDotsState extends State<FloatingBotanicalDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late List<_Dot> _dots;
  final _rng = Random();

  @override
  void initState() {
    super.initState();
    _dots = List.generate(widget.dotCount, (_) => _Dot.random(_rng));
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 20))..repeat();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) => CustomPaint(
        painter: _DotsPainter(_dots, _ctrl.value),
        child: child,
      ),
      child: widget.child ?? const SizedBox.expand(),
    );
  }
}

class _Dot {
  final double x, y, radius, speed, phase;
  final Color color;
  _Dot({required this.x, required this.y, required this.radius, required this.speed, required this.phase, required this.color});

  factory _Dot.random(Random rng) {
    final colors = [
      AppTheme.accent.withValues(alpha: 0.12),
      AppTheme.positive.withValues(alpha: 0.10),
      AppTheme.warmTone.withValues(alpha: 0.08),
      AppTheme.cardPink.withValues(alpha: 0.20),
      AppTheme.moodLove.withValues(alpha: 0.10),
    ];
    return _Dot(x: rng.nextDouble(), y: rng.nextDouble(), radius: 3 + rng.nextDouble() * 6,
      speed: 0.3 + rng.nextDouble() * 0.7, phase: rng.nextDouble() * 2 * pi, color: colors[rng.nextInt(colors.length)]);
  }
}

class _DotsPainter extends CustomPainter {
  final List<_Dot> dots;
  final double progress;
  _DotsPainter(this.dots, this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    for (final dot in dots) {
      final t = progress * dot.speed * 2 * pi + dot.phase;
      final dx = dot.x * size.width + sin(t) * 20;
      final dy = dot.y * size.height + cos(t * 0.7) * 15;
      canvas.drawCircle(Offset(dx, dy), dot.radius, Paint()..color = dot.color);
    }
  }

  @override
  bool shouldRepaint(covariant _DotsPainter old) => true;
}

/// Animated botanical branch widget.
class AnimatedBotanicalBranch extends StatefulWidget {
  final double size;
  final Color? color;
  const AnimatedBotanicalBranch({super.key, this.size = 200, this.color});

  @override
  State<AnimatedBotanicalBranch> createState() => _AnimatedBotanicalBranchState();
}

class _AnimatedBotanicalBranchState extends State<AnimatedBotanicalBranch>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _grow;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..forward();
    _grow = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _grow,
      builder: (_, __) => CustomPaint(
        size: Size(widget.size, widget.size),
        painter: _BranchPainter(color: widget.color ?? AppTheme.accent, progress: _grow.value),
      ),
    );
  }
}

class _BranchPainter extends CustomPainter {
  final Color color;
  final double progress;
  _BranchPainter({required this.color, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 1.8..strokeCap = StrokeCap.round;
    final cx = size.width / 2;
    final cy = size.height / 2;
    final s = min(size.width, size.height) * 0.4;

    // Main stem
    final stem = Path()..moveTo(cx, cy + s * 0.6 * progress)
      ..cubicTo(cx - s * 0.1, cy + s * 0.2, cx + s * 0.05, cy - s * 0.1, cx, cy - s * 0.5 * progress);
    canvas.drawPath(stem, paint);

    if (progress < 0.3) return;
    final lp = Paint()..color = color.withValues(alpha: 0.25)..style = PaintingStyle.fill;

    _leaf(canvas, Offset(cx, cy - s * 0.1), -0.4, s * 0.25 * progress, paint, lp);
    _leaf(canvas, Offset(cx, cy + s * 0.1), 0.3, s * 0.22 * progress, paint, lp);
    _leaf(canvas, Offset(cx, cy - s * 0.3), -0.5, s * 0.2 * progress, paint, lp);

    // Berries
    final dp = Paint()..color = AppTheme.warmTone.withValues(alpha: 0.5 * progress);
    canvas.drawCircle(Offset(cx - s * 0.15, cy - s * 0.35), 3, dp);
    canvas.drawCircle(Offset(cx + s * 0.18, cy - s * 0.25), 2.5, dp);
    canvas.drawCircle(Offset(cx + s * 0.12, cy - s * 0.42), 3.5, dp);
  }

  void _leaf(Canvas canvas, Offset start, double angle, double len, Paint stroke, Paint fill) {
    final dx = cos(angle) * len; final dy = sin(angle) * len;
    final end = Offset(start.dx + dx, start.dy + dy);
    final m1 = Offset(start.dx + dx * 0.5 - sin(angle) * len * 0.3, start.dy + dy * 0.5 + cos(angle) * len * 0.3);
    final m2 = Offset(start.dx + dx * 0.5 + sin(angle) * len * 0.3, start.dy + dy * 0.5 - cos(angle) * len * 0.3);
    final p = Path()..moveTo(start.dx, start.dy)..quadraticBezierTo(m1.dx, m1.dy, end.dx, end.dy)..quadraticBezierTo(m2.dx, m2.dy, start.dx, start.dy);
    canvas.drawPath(p, fill);
    canvas.drawPath(p, stroke);
  }

  @override
  bool shouldRepaint(covariant _BranchPainter old) => old.progress != progress;
}
