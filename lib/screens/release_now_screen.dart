import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_theme.dart';

class ReleaseNowScreen extends StatefulWidget {
  const ReleaseNowScreen({super.key});

  @override
  State<ReleaseNowScreen> createState() => _ReleaseNowScreenState();
}

class _ReleaseNowScreenState extends State<ReleaseNowScreen>
    with TickerProviderStateMixin {
  // ── Phase management ──
  _ReleasePhase _phase = _ReleasePhase.write;
  final TextEditingController _textCtrl = TextEditingController();
  String _capturedText = '';

  // ── Animation controllers ──
  late AnimationController _paperDropCtrl;   // paper falls into jar
  late AnimationController _dissolveCtrl;    // paper burns/dissolves
  late AnimationController _completionCtrl;  // final message fades in

  late Animation<double> _paperSlide;        // 0 = top position, 1 = in jar
  late Animation<double> _paperFade;         // paper fades as it burns
  late Animation<double> _paperScale;        // shrinks as burns
  late Animation<Color?> _paperColor;        // white → amber → transparent
  late Animation<double> _completionFade;

  // Particles
  final List<_Particle> _particles = [];
  late AnimationController _particleCtrl;

  @override
  void initState() {
    super.initState();

    _paperDropCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _dissolveCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800));
    _completionCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _particleCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600));

    // Paper drop animation
    _paperSlide = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _paperDropCtrl, curve: Curves.easeInCubic),
    );

    // Dissolve animations
    _paperFade = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _dissolveCtrl, curve: const Interval(0.3, 1.0, curve: Curves.easeOut)),
    );
    _paperScale = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _dissolveCtrl, curve: const Interval(0.2, 0.9, curve: Curves.easeIn)),
    );
    _paperColor = ColorTween(begin: Colors.white, end: Colors.transparent).animate(
      CurvedAnimation(parent: _dissolveCtrl, curve: const Interval(0.0, 0.8)),
    );

    _completionFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _completionCtrl, curve: Curves.easeOut),
    );

    // Generate particles
    final rng = Random(42);
    for (int i = 0; i < 22; i++) {
      _particles.add(_Particle(
        angle: rng.nextDouble() * 2 * pi,
        distance: 40 + rng.nextDouble() * 100,
        size: 3 + rng.nextDouble() * 5,
        color: _randomEmberColor(rng),
        delay: rng.nextDouble() * 0.4,
      ));
    }
  }

  Color _randomEmberColor(Random rng) {
    final colors = [
      const Color(0xFFE8A87C),
      const Color(0xFFD4956A),
      const Color(0xFFC8855A),
      const Color(0xFFDDB892),
      AppTheme.warmTone,
    ];
    return colors[rng.nextInt(colors.length)];
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    _paperDropCtrl.dispose();
    _dissolveCtrl.dispose();
    _completionCtrl.dispose();
    _particleCtrl.dispose();
    super.dispose();
  }

  Future<void> _onDone() async {
    if (_textCtrl.text.trim().isEmpty) return;
    _capturedText = _textCtrl.text.trim();
    FocusScope.of(context).unfocus();

    // Phase 1: show paper card
    setState(() => _phase = _ReleasePhase.paper);
    await Future.delayed(const Duration(milliseconds: 600));

    // Phase 2: paper drops into jar
    setState(() => _phase = _ReleasePhase.dropping);
    _paperDropCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 1000));

    // Phase 3: paper dissolves
    setState(() => _phase = _ReleasePhase.dissolving);
    _dissolveCtrl.forward();
    _particleCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 2000));

    // Phase 4: completion
    setState(() => _phase = _ReleasePhase.done);
    _completionCtrl.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _phase == _ReleasePhase.done ? AppTheme.positiveSoft : AppTheme.canvas,
      appBar: _phase == _ReleasePhase.write || _phase == _ReleasePhase.paper
          ? AppBar(
              title: const Text('Release Now'),
              backgroundColor: AppTheme.canvas,
              elevation: 0,
              scrolledUnderElevation: 0,
            )
          : null,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        child: switch (_phase) {
          _ReleasePhase.write => _buildWrite(),
          _ReleasePhase.paper => _buildPaperStage(),
          _ReleasePhase.dropping => _buildDroppingStage(),
          _ReleasePhase.dissolving => _buildDissolvingStage(),
          _ReleasePhase.done => _buildDone(),
        },
      ),
    );
  }

  // ── Phase 1: Write ──────────────────────────────────────────────────────────
  Widget _buildWrite() {
    return SafeArea(
      key: const ValueKey('write'),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.warmSoft,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.warmTone.withValues(alpha: 0.25)),
              ),
              child: Row(
                children: [
                  const Text('🕯️', style: TextStyle(fontSize: 28)),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Write it down', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                        const SizedBox(height: 3),
                        Text('Let your thoughts flow freely. This is for you only.', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary, height: 1.4)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Text area
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.border),
                ),
                child: TextField(
                  controller: _textCtrl,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  style: GoogleFonts.inter(fontSize: 15, color: AppTheme.textPrimary, height: 1.7),
                  decoration: InputDecoration(
                    hintText: 'What is weighing on you right now?\nWrite it all out...',
                    hintStyle: GoogleFonts.inter(fontSize: 15, color: AppTheme.textMuted, height: 1.7),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.all(20),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity, height: 52,
              child: ElevatedButton.icon(
                onPressed: _onDone,
                icon: const Icon(Icons.local_fire_department_outlined, size: 20),
                label: const Text('Done — release it'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.warmTone,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  textStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Phase 2: Paper card shown ───────────────────────────────────────────────
  Widget _buildPaperStage() {
    return Center(
      key: const ValueKey('paper'),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Your thoughts', style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textMuted, letterSpacing: 0.5)),
            const SizedBox(height: 16),
            _PaperCard(text: _capturedText),
            const SizedBox(height: 32),
            Text('Letting go...', style: GoogleFonts.inter(fontSize: 15, color: AppTheme.textSecondary)),
          ],
        ),
      ),
    );
  }

  // ── Phase 3: Paper drops into jar ──────────────────────────────────────────
  Widget _buildDroppingStage() {
    return AnimatedBuilder(
      animation: _paperDropCtrl,
      key: const ValueKey('dropping'),
      builder: (_, __) {
        final t = _paperSlide.value;
        return Stack(
          children: [
            // Jar at bottom center
            Positioned(
              bottom: 80, left: 0, right: 0,
              child: Center(child: _JarWidget()),
            ),
            // Paper sliding down
            Positioned(
              top: lerpDouble(80, MediaQuery.of(context).size.height * 0.45, t),
              left: 0, right: 0,
              child: Center(
                child: Transform.scale(
                  scale: lerpDouble(1.0, 0.55, t)!,
                  child: Opacity(
                    opacity: lerpDouble(1.0, 0.6, t)!,
                    child: _PaperCard(text: _capturedText, compact: true),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ── Phase 4: Dissolve ───────────────────────────────────────────────────────
  Widget _buildDissolvingStage() {
    return AnimatedBuilder(
      animation: Listenable.merge([_dissolveCtrl, _particleCtrl]),
      key: const ValueKey('dissolving'),
      builder: (_, __) {
        final center = Offset(
          MediaQuery.of(context).size.width / 2,
          MediaQuery.of(context).size.height * 0.45,
        );
        return Stack(
          children: [
            // Jar
            Positioned(
              bottom: 80, left: 0, right: 0,
              child: Center(child: _JarWidget()),
            ),
            // Dissolving paper
            Positioned(
              top: MediaQuery.of(context).size.height * 0.32,
              left: 0, right: 0,
              child: Center(
                child: FadeTransition(
                  opacity: _paperFade,
                  child: ScaleTransition(
                    scale: _paperScale,
                    child: _PaperCard(
                      text: _capturedText,
                      compact: true,
                      overrideColor: _paperColor.value,
                    ),
                  ),
                ),
              ),
            ),
            // Particles
            ..._particles.map((p) {
              final t = (_particleCtrl.value - p.delay).clamp(0.0, 1.0);
              if (t <= 0) return const SizedBox.shrink();
              final dx = cos(p.angle) * p.distance * t;
              final dy = sin(p.angle) * p.distance * t - (30 * t * t); // arc upward
              return Positioned(
                left: center.dx + dx - p.size / 2,
                top: center.dy + dy - p.size / 2,
                child: Opacity(
                  opacity: (1.0 - t).clamp(0.0, 1.0),
                  child: Container(
                    width: p.size,
                    height: p.size,
                    decoration: BoxDecoration(
                      color: p.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }

  // ── Phase 5: Completion ─────────────────────────────────────────────────────
  Widget _buildDone() {
    return FadeTransition(
      opacity: _completionFade,
      key: const ValueKey('done'),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🌿', style: TextStyle(fontSize: 64)),
              const SizedBox(height: 28),
              Text(
                'Let it go.',
                style: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.w800, color: AppTheme.textPrimary, letterSpacing: -1),
              ),
              const SizedBox(height: 12),
              Text(
                'You are free.',
                style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w500, color: AppTheme.positive, letterSpacing: -0.3),
              ),
              const SizedBox(height: 16),
              Text(
                'Your thoughts don\'t define you.\nYou chose to release them — that takes courage.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textSecondary, height: 1.7),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity, height: 52,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.positive, elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text('I feel lighter', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  setState(() {
                    _phase = _ReleasePhase.write;
                    _textCtrl.clear();
                    _paperDropCtrl.reset();
                    _dissolveCtrl.reset();
                    _completionCtrl.reset();
                    _particleCtrl.reset();
                  });
                },
                child: Text('Write more', style: GoogleFonts.inter(color: AppTheme.textMuted)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Paper card widget ──────────────────────────────────────────────────────────
class _PaperCard extends StatelessWidget {
  final String text;
  final bool compact;
  final Color? overrideColor;

  const _PaperCard({required this.text, this.compact = false, this.overrideColor});

  @override
  Widget build(BuildContext context) {
    final bgColor = overrideColor ?? Colors.white;
    return Container(
      width: compact ? 180 : double.infinity,
      constraints: compact ? const BoxConstraints(maxHeight: 160) : const BoxConstraints(maxHeight: 280),
      padding: EdgeInsets.all(compact ? 14 : 20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 16, offset: const Offset(0, 4)),
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 4, offset: const Offset(0, 1)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ruled lines decoration
          if (!compact) ...[
            Container(height: 1, color: const Color(0xFFE8E8E8), margin: const EdgeInsets.only(bottom: 8)),
            Container(height: 1, color: const Color(0xFFE8E8E8), margin: const EdgeInsets.only(bottom: 8)),
          ],
          Text(
            text,
            maxLines: compact ? 6 : 12,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(fontSize: compact ? 11 : 14, color: const Color(0xFF333333), height: 1.6),
          ),
        ],
      ),
    );
  }
}

// ── Jar widget (drawn with CustomPainter) ──────────────────────────────────────
class _JarWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(100, 120),
      painter: _JarPainter(),
    );
  }
}

class _JarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Glass fill
    final fillPaint = Paint()
      ..color = const Color(0xFFE8F4F8).withValues(alpha: 0.7)
      ..style = PaintingStyle.fill;

    // Jar outline
    final outlinePaint = Paint()
      ..color = const Color(0xFF9BB8C4).withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Jar body path
    final body = Path()
      ..moveTo(w * 0.18, h * 0.22)
      ..lineTo(w * 0.10, h * 0.95)
      ..arcToPoint(Offset(w * 0.90, h * 0.95), radius: const Radius.circular(8))
      ..lineTo(w * 0.82, h * 0.22)
      ..close();

    canvas.drawPath(body, fillPaint);
    canvas.drawPath(body, outlinePaint);

    // Jar neck / lid rim
    final neckPaint = Paint()
      ..color = const Color(0xFF9BB8C4).withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;

    final neck = Rect.fromLTWH(w * 0.25, h * 0.12, w * 0.50, h * 0.12);
    canvas.drawRRect(RRect.fromRectAndRadius(neck, const Radius.circular(4)), neckPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(neck, const Radius.circular(4)), outlinePaint);

    // Highlight shine
    final shinePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(w * 0.22, h * 0.30), Offset(w * 0.18, h * 0.70), shinePaint);
  }

  @override
  bool shouldRepaint(_) => false;
}

// ── Phase enum ──────────────────────────────────────────────────────────────────
enum _ReleasePhase { write, paper, dropping, dissolving, done }

// ── Particle data ──────────────────────────────────────────────────────────────
class _Particle {
  final double angle;
  final double distance;
  final double size;
  final Color color;
  final double delay;

  _Particle({
    required this.angle,
    required this.distance,
    required this.size,
    required this.color,
    required this.delay,
  });
}

// ── Helper ──────────────────────────────────────────────────────────────────────
double? lerpDouble(double a, double b, double t) => a + (b - a) * t;
