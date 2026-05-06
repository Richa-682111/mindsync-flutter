import 'dart:async';
import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';

class BreathingAnimationWidget extends StatefulWidget {
  const BreathingAnimationWidget({super.key});

  @override
  State<BreathingAnimationWidget> createState() => _BreathingAnimationWidgetState();
}

class _BreathingAnimationWidgetState extends State<BreathingAnimationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  int _timeLeft = 60;
  Timer? _timer;
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    _scaleAnimation = Tween<double>(begin: 0.55, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() {
          _timeLeft--;
        });
      } else {
        timer.cancel();
        _controller.stop();
        setState(() {
          _isRunning = false;
        });
      }
    });
  }

  void _toggleTimer() {
    if (_isRunning) {
      _timer?.cancel();
      _controller.stop();
      setState(() {
        _isRunning = false;
      });
    } else {
      if (_timeLeft > 0) {
        _controller.repeat(reverse: true);
        _startTimer();
        setState(() {
          _isRunning = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  String get timerText {
    int minutes = _timeLeft ~/ 60;
    int seconds = _timeLeft % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        final isBreathingIn = _controller.status == AnimationStatus.forward || _controller.status == AnimationStatus.dismissed;
        return Column(
          children: [
            SizedBox(
              width: 200,
              height: 200,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Outer glow ring
                  Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF76C893).withValues(alpha: 0.08 + (_scaleAnimation.value * 0.1)),
                    ),
                  ),
                  // Breathing circle
                  Container(
                    width: 80 + (80 * _scaleAnimation.value),
                    height: 80 + (80 * _scaleAnimation.value),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF76C893).withValues(alpha: 0.2 + (_scaleAnimation.value * 0.15)),
                    ),
                  ),
                  // Label
                  Text(
                    isBreathingIn ? 'Breathe in' : 'Breathe out',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF4C986C),
                      letterSpacing: -0.1,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              timerText,
              style: GoogleFonts.inter(
                fontSize: 28,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Follow the circle',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppTheme.textMuted,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _timeLeft > 0 ? _toggleTimer : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isRunning ? AppTheme.surfaceDim : AppTheme.accent,
                foregroundColor: _isRunning ? AppTheme.textPrimary : Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              ),
              child: Text(
                _timeLeft == 0 ? 'Done' : (_isRunning ? 'Pause' : 'Start Breathing'),
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
