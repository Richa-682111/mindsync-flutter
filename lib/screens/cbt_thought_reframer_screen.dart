import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_theme.dart';
import '../utils/cbt_data.dart';

enum _ReframingPhase { inputThought, selectDistortion, readResponse, reframeThought, releaseAnimation }

class CBTThoughtReframerScreen extends StatefulWidget {
  const CBTThoughtReframerScreen({super.key});

  @override
  State<CBTThoughtReframerScreen> createState() => _CBTThoughtReframerScreenState();
}

class _CBTThoughtReframerScreenState extends State<CBTThoughtReframerScreen> with TickerProviderStateMixin {
  _ReframingPhase _phase = _ReframingPhase.inputThought;
  
  // Data
  final TextEditingController _thoughtCtrl = TextEditingController();
  final TextEditingController _reframeCtrl = TextEditingController();
  String? _selectedDistortionId;
  String _supportiveResponse = '';

  // Animation for phase transition
  void _nextPhase(_ReframingPhase next) {
    FocusScope.of(context).unfocus();
    setState(() => _phase = next);
  }

  // Final Animation Controllers
  late AnimationController _jarAnimCtrl;
  late Animation<double> _envelopeDrop;
  late Animation<double> _envelopeScale;
  late Animation<double> _envelopeOpacity;
  late Animation<double> _fireOpacity;
  late Animation<double> _jarFadeOut;

  @override
  void initState() {
    super.initState();
    _jarAnimCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 5000));
    
    // Envelope falls 0-20%
    _envelopeDrop = Tween<double>(begin: -300, end: 100).animate(
      CurvedAnimation(parent: _jarAnimCtrl, curve: const Interval(0.0, 0.2, curve: Curves.easeInCubic)),
    );
    // Envelope scales down to fit jar
    _envelopeScale = Tween<double>(begin: 1.0, end: 0.6).animate(
      CurvedAnimation(parent: _jarAnimCtrl, curve: const Interval(0.0, 0.2, curve: Curves.easeOut)),
    );
    // Fire starts at 20%, peaks at 40%, fades at 70%
    _fireOpacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.0), weight: 20),
    ]).animate(CurvedAnimation(parent: _jarAnimCtrl, curve: Curves.easeInOut));
    // Envelope burns (fades out) 30%-50%
    _envelopeOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _jarAnimCtrl, curve: const Interval(0.3, 0.5, curve: Curves.easeOut)),
    );
    // Whole jar fades out at the very end
    _jarFadeOut = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _jarAnimCtrl, curve: const Interval(0.8, 1.0, curve: Curves.easeOut)),
    );

    _jarAnimCtrl.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (mounted) Navigator.pop(context);
      }
    });
  }

  @override
  void dispose() {
    _thoughtCtrl.dispose();
    _reframeCtrl.dispose();
    _jarAnimCtrl.dispose();
    super.dispose();
  }

  void _startReleaseAnimation() {
    _nextPhase(_ReframingPhase.releaseAnimation);
    _jarAnimCtrl.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.canvas,
      appBar: AppBar(
        title: const Text('Thought Reframer'),
        backgroundColor: AppTheme.canvas,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_phase != _ReframingPhase.releaseAnimation) ...[
                Text(
                  'Let’s gently challenge this thought 🌿',
                  style: GoogleFonts.inter(fontSize: 15, color: AppTheme.textSecondary),
                ),
                const SizedBox(height: 32),
              ],
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 600),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero).animate(animation),
                        child: child,
                      ),
                    );
                  },
                  child: _buildCurrentPhase(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentPhase() {
    switch (_phase) {
      case _ReframingPhase.inputThought:
        return _buildInputThought();
      case _ReframingPhase.selectDistortion:
        return _buildSelectDistortion();
      case _ReframingPhase.readResponse:
        return _buildReadResponse();
      case _ReframingPhase.reframeThought:
        return _buildReframeThought();
      case _ReframingPhase.releaseAnimation:
        return _buildReleaseAnimation();
    }
  }

  // ── Step 1 ──
  Widget _buildInputThought() {
    return Column(
      key: const ValueKey('step1'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "What’s bothering you right now?",
          style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w700, color: AppTheme.textPrimary, letterSpacing: -0.5),
        ),
        const SizedBox(height: 24),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.border),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: TextField(
            controller: _thoughtCtrl,
            maxLines: 5,
            style: GoogleFonts.inter(fontSize: 16, color: AppTheme.textPrimary, height: 1.5),
            decoration: InputDecoration(
              hintText: "e.g., I feel like I'm failing at everything...",
              hintStyle: GoogleFonts.inter(color: AppTheme.textMuted),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(20),
            ),
            onChanged: (val) => setState(() {}),
          ),
        ),
        const Spacer(),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _thoughtCtrl.text.trim().isEmpty ? null : () => _nextPhase(_ReframingPhase.selectDistortion),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: AppTheme.accent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Next Step', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600)),
          ),
        ),
      ],
    );
  }

  // ── Step 2 ──
  Widget _buildSelectDistortion() {
    return Column(
      key: const ValueKey('step2'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "What kind of thought is this?",
          style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w700, color: AppTheme.textPrimary, letterSpacing: -0.5),
        ),
        const SizedBox(height: 8),
        Text(
          "Our minds sometimes play tricks on us. Select the one that fits best.",
          style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textSecondary, height: 1.4),
        ),
        const SizedBox(height: 24),
        Expanded(
          child: ListView.separated(
            itemCount: CBTData.distortions.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final d = CBTData.distortions[index];
              final isSelected = _selectedDistortionId == d['id'];
              return GestureDetector(
                onTap: () {
                  setState(() => _selectedDistortionId = d['id']);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.accentSoft : AppTheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? AppTheme.accent : AppTheme.border,
                      width: isSelected ? 1.5 : 1.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(d['icon']!, style: const TextStyle(fontSize: 24)),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              d['title']!,
                              style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                            ),
                            if (isSelected) ...[
                              const SizedBox(height: 4),
                              Text(
                                d['description']!,
                                style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textSecondary, height: 1.4),
                              ),
                            ]
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _selectedDistortionId == null ? null : () {
              _supportiveResponse = CBTData.getRandomResponse(_selectedDistortionId!);
              _nextPhase(_ReframingPhase.readResponse);
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: AppTheme.accent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Analyze Thought', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600)),
          ),
        ),
      ],
    );
  }

  // ── Step 3 ──
  Widget _buildReadResponse() {
    return Column(
      key: const ValueKey('step3'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 40),
        Center(
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppTheme.positiveSoft,
              shape: BoxShape.circle,
            ),
            child: const Text('🌿', style: TextStyle(fontSize: 48)),
          ),
        ),
        const SizedBox(height: 40),
        Text(
          _supportiveResponse,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w600, color: AppTheme.textPrimary, height: 1.4, letterSpacing: -0.5),
        ),
        const Spacer(),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => _nextPhase(_ReframingPhase.reframeThought),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: AppTheme.accent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Reframe My Thought', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600)),
          ),
        ),
      ],
    );
  }

  // ── Step 4 ──
  Widget _buildReframeThought() {
    return Column(
      key: const ValueKey('step4'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "How could you rewrite this thought more kindly?",
          style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w700, color: AppTheme.textPrimary, letterSpacing: -0.5, height: 1.3),
        ),
        const SizedBox(height: 8),
        Text(
          "Original: \"${_thoughtCtrl.text}\"",
          style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textSecondary, fontStyle: FontStyle.italic),
        ),
        const SizedBox(height: 24),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.positive.withValues(alpha: 0.5)),
            boxShadow: [
              BoxShadow(color: AppTheme.positive.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: TextField(
            controller: _reframeCtrl,
            maxLines: 5,
            style: GoogleFonts.inter(fontSize: 16, color: AppTheme.textPrimary, height: 1.5),
            decoration: InputDecoration(
              hintText: "e.g., I made a mistake, but I'm learning...",
              hintStyle: GoogleFonts.inter(color: AppTheme.textMuted),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(20),
            ),
            onChanged: (val) => setState(() {}),
          ),
        ),
        const Spacer(),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _reframeCtrl.text.trim().isEmpty ? null : _startReleaseAnimation,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: AppTheme.positive,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Release Original Thought', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
          ),
        ),
      ],
    );
  }

  // ── Step 5 ──
  Widget _buildReleaseAnimation() {
    return FadeTransition(
      key: const ValueKey('step5'),
      opacity: _jarFadeOut,
      child: Center(
        child: AnimatedBuilder(
          animation: _jarAnimCtrl,
          builder: (context, child) {
            return Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                // The Jar
                Container(
                  width: 140,
                  height: 180,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                    ),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 2),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      // Envelope dropping inside the jar
                      Transform.translate(
                        offset: Offset(0, _envelopeDrop.value),
                        child: Transform.scale(
                          scale: _envelopeScale.value,
                          child: Opacity(
                            opacity: _envelopeOpacity.value,
                            child: Container(
                              width: 100,
                              height: 60,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFDE8C4),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xFFDCA970)),
                                boxShadow: [
                                  BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4, offset: const Offset(0, 2)),
                                ],
                              ),
                              child: Stack(
                                children: [
                                  // Envelope flap drawing
                                  CustomPaint(
                                    size: const Size(100, 60),
                                    painter: _EnvelopePainter(),
                                  ),
                                  Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        _thoughtCtrl.text,
                                        style: GoogleFonts.inter(fontSize: 8, color: Colors.black87),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Fire inside the jar
                      if (_fireOpacity.value > 0)
                        Opacity(
                          opacity: _fireOpacity.value,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: const _FireAnimation(),
                          ),
                        ),
                    ],
                  ),
                ),
                // Jar Lid (drawn on top)
                Positioned(
                  top: -10,
                  child: Container(
                    width: 150,
                    height: 15,
                    decoration: BoxDecoration(
                      color: const Color(0xFFB08B6E),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: const Color(0xFF8B6B50)),
                    ),
                  ),
                ),
                // Final text
                if (_jarFadeOut.value < 0.5)
                  Positioned(
                    bottom: -60,
                    child: Opacity(
                      opacity: (1.0 - _jarFadeOut.value * 2).clamp(0.0, 1.0),
                      child: Text(
                        "Thought Released.",
                        style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.positive),
                      ),
                    ),
                  )
              ],
            );
          },
        ),
      ),
    );
  }
}

// Custom Painter for Envelope Flap
class _EnvelopePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFDCA970)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width / 2, size.height / 2 + 5);
    path.lineTo(size.width, 0);

    path.moveTo(0, size.height);
    path.lineTo(size.width / 2, size.height / 2 - 5);
    path.lineTo(size.width, size.height);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Simple beautiful fire animation using particles/blurred circles
class _FireAnimation extends StatefulWidget {
  const _FireAnimation();

  @override
  State<_FireAnimation> createState() => _FireAnimationState();
}

class _FireAnimationState extends State<_FireAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        return SizedBox(
          width: 80,
          height: 100,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              _buildFlame(width: 60, height: 80 + 10 * _ctrl.value, color: Colors.orange.withValues(alpha: 0.6), offset: Offset(-5, -5 * _ctrl.value)),
              _buildFlame(width: 50, height: 60 + 15 * _ctrl.value, color: Colors.deepOrange.withValues(alpha: 0.8), offset: Offset(5, -10 * (1 - _ctrl.value))),
              _buildFlame(width: 30, height: 40 + 20 * _ctrl.value, color: Colors.yellow.withValues(alpha: 0.9), offset: const Offset(0, 0)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFlame({required double width, required double height, required Color color, required Offset offset}) {
    return Transform.translate(
      offset: offset,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: color,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(50),
            topRight: Radius.circular(50),
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 15, spreadRadius: 5),
          ],
        ),
      ),
    );
  }
}
