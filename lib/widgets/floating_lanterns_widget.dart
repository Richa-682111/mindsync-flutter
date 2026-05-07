import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class FloatingLanternsWidget extends StatefulWidget {
  const FloatingLanternsWidget({super.key});

  @override
  State<FloatingLanternsWidget> createState() => _FloatingLanternsWidgetState();
}

class _FloatingLanternsWidgetState extends State<FloatingLanternsWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: SizedBox(
        width: double.infinity,
        height: 240,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return CustomPaint(
              painter: _LanternPainter(progress: _controller.value),
            );
          },
        ),
      ),
    );
  }
}

class _LanternPainter extends CustomPainter {
  const _LanternPainter({required this.progress});

  final double progress;

  static const List<_LanternSpec> _specs = [
    _LanternSpec(x: 0.16, speed: 0.35, size: 0.94, phase: 0.10, drift: 14),
    _LanternSpec(x: 0.32, speed: 0.48, size: 0.76, phase: 0.62, drift: 11),
    _LanternSpec(x: 0.50, speed: 0.40, size: 1.02, phase: 0.28, drift: 16),
    _LanternSpec(x: 0.68, speed: 0.55, size: 0.82, phase: 0.82, drift: 12),
    _LanternSpec(x: 0.84, speed: 0.44, size: 0.90, phase: 0.46, drift: 13),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final bg = Paint()
      ..shader = LinearGradient(
        colors: [AppTheme.canvas, AppTheme.canvas.withValues(alpha: 0.98)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(rect);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(16)),
      bg,
    );

    for (final spec in _specs) {
      _paintLantern(canvas, size, spec);
    }
  }

  void _paintLantern(Canvas canvas, Size size, _LanternSpec spec) {
    final t = (progress * spec.speed + spec.phase) % 1.0;
    final xBase = size.width * spec.x;
    final dx = math.sin((t * math.pi * 2) + spec.phase * 5) * spec.drift;
    final x = xBase + dx;
    final y = size.height + 20 - (size.height + 80) * t;

    final scale = spec.size;
    final lanternWidth = 24.0 * scale;
    final lanternHeight = 36.0 * scale;
    final glowRadius = 24.0 * scale;
    final flicker = 0.78 + (0.22 * math.sin((t * math.pi * 6) + spec.phase));

    final glowPaint = Paint()
      ..color = AppTheme.warmTone.withValues(alpha: 0.18 * flicker)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14);
    canvas.drawCircle(Offset(x, y), glowRadius, glowPaint);

    final bodyRect = Rect.fromCenter(
      center: Offset(x, y),
      width: lanternWidth,
      height: lanternHeight,
    );
    final body = RRect.fromRectAndRadius(bodyRect, Radius.circular(8 * scale));
    final bodyPaint = Paint()
      ..shader = LinearGradient(
        colors: [AppTheme.warmSoft, AppTheme.warmTone.withValues(alpha: 0.85)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(bodyRect);
    canvas.drawRRect(body, bodyPaint);

    final framePaint = Paint()
      ..color = AppTheme.warmTone.withValues(alpha: 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1;
    canvas.drawRRect(body, framePaint);

    final centerLine = Paint()
      ..color = AppTheme.warmTone.withValues(alpha: 0.30)
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(x, y - lanternHeight * 0.42),
      Offset(x, y + lanternHeight * 0.42),
      centerLine,
    );
  }

  @override
  bool shouldRepaint(covariant _LanternPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class _LanternSpec {
  const _LanternSpec({
    required this.x,
    required this.speed,
    required this.size,
    required this.phase,
    required this.drift,
  });

  final double x;
  final double speed;
  final double size;
  final double phase;
  final double drift;
}
