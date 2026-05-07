import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../providers/mood_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/app_theme.dart';
import 'profile_dashboard_screen.dart';
import 'meditation_library_screen.dart';
import 'mental_health_resources_screen.dart';
import 'mood_happy_screen.dart';
import 'mood_stressed_screen.dart';
import 'mood_anxiety_screen.dart';

class MoodSelectionScreen extends StatelessWidget {
  const MoodSelectionScreen({super.key});

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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ProfileDashboardScreen(),
                ),
              ),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppTheme.accentSoft,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.person_outline,
                  color: AppTheme.accent,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Container(
        color: AppTheme.canvas,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
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
              const SizedBox(height: 48),
              Text(
                'How are you feeling right now?',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: AppTheme.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 48),

              // ── Mood cards with animated emojis ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _AnimatedMoodIcon(
                    moodType: MoodType.happy,
                    label: 'Happy',
                    onTap: () => _selectMood(context, 'Happy'),
                  ),
                  _AnimatedMoodIcon(
                    moodType: MoodType.stressed,
                    label: 'Stressed',
                    onTap: () => _selectMood(context, 'Stressed'),
                  ),
                  _AnimatedMoodIcon(
                    moodType: MoodType.anxious,
                    label: 'Anxiety',
                    onTap: () => _selectMood(context, 'Anxiety'),
                  ),
                ],
              ),
            const SizedBox(height: 64),
            Wrap(
              spacing: 10,
              children: [
                OutlinedButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const MeditationLibraryScreen(),
                    ),
                  ),
                  icon: const Icon(Icons.self_improvement_outlined, size: 16),
                  label: const Text('Meditation Library'),
                ),
                OutlinedButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const MentalHealthResourcesScreen(),
                    ),
                  ),
                  icon: const Icon(Icons.health_and_safety_outlined, size: 16),
                  label: const Text('Help & Resources'),
                ),
              ],
            ),
          ],
        ),
      ),
      ),
    );
  }

  void _selectMood(BuildContext context, String mood) {
    final moodProvider = Provider.of<MoodProvider>(context, listen: false);
    moodProvider.saveMood(mood);

    Widget nextScreen;
    if (mood == 'Happy') {
      nextScreen = const MoodHappyScreen();
    } else if (mood == 'Stressed') {
      nextScreen = const MoodStressedScreen();
    } else {
      nextScreen = const MoodAnxietyScreen();
    }

    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => nextScreen,
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 250),
      ),
    );
  }
}

// ── Mood type enum ──────────────────────────────────────────────────────────────
enum MoodType { happy, stressed, anxious }

// ── Animated mood icon ─────────────────────────────────────────────────────────
class _AnimatedMoodIcon extends StatefulWidget {
  final MoodType moodType;
  final String label;
  final VoidCallback onTap;

  const _AnimatedMoodIcon({
    required this.moodType,
    required this.label,
    required this.onTap,
  });

  @override
  State<_AnimatedMoodIcon> createState() => _AnimatedMoodIconState();
}

class _AnimatedMoodIconState extends State<_AnimatedMoodIcon>
    with TickerProviderStateMixin {
  bool _pressed = false;
  bool _hovered = false;

  // Happy: gentle bob + glow pulse
  late AnimationController _happyBobCtrl;
  late Animation<double> _happyBob;

  // Stressed: periodic nose-puff shake
  late AnimationController _stressShakeCtrl;
  late Animation<double> _stressShakeX;
  late Animation<double> _stressScale;

  // Anxious: sweat drop falls + color shifts blue
  late AnimationController _anxiousCtrl;
  late Animation<double> _sweatDrop;
  late Animation<double> _blueTint;

  // Hover scale (all moods)
  late AnimationController _hoverCtrl;
  late Animation<double> _hoverScale;

  @override
  void initState() {
    super.initState();

    // Hover
    _hoverCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _hoverScale = Tween<double>(
      begin: 1.0,
      end: 1.22,
    ).animate(CurvedAnimation(parent: _hoverCtrl, curve: Curves.easeOut));

    // Happy bob
    _happyBobCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
    _happyBob = Tween<double>(
      begin: 0.0,
      end: -6.0,
    ).animate(CurvedAnimation(parent: _happyBobCtrl, curve: Curves.easeInOut));

    // Stressed shake
    _stressShakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _stressShakeX =
        TweenSequence<double>([
          TweenSequenceItem(tween: Tween(begin: 0, end: -4), weight: 1),
          TweenSequenceItem(tween: Tween(begin: -4, end: 4), weight: 2),
          TweenSequenceItem(tween: Tween(begin: 4, end: -3), weight: 2),
          TweenSequenceItem(tween: Tween(begin: -3, end: 3), weight: 2),
          TweenSequenceItem(tween: Tween(begin: 3, end: 0), weight: 1),
        ]).animate(
          CurvedAnimation(parent: _stressShakeCtrl, curve: Curves.easeInOut),
        );
    _stressScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.12), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1.12, end: 1.0), weight: 1),
    ]).animate(_stressShakeCtrl);

    // Repeat shake every 2.5s
    if (widget.moodType == MoodType.stressed) {
      _stressShakeCtrl.addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          Future.delayed(const Duration(milliseconds: 2100), () {
            if (mounted) _stressShakeCtrl.forward(from: 0);
          });
        }
      });
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) _stressShakeCtrl.forward();
      });
    }

    // Anxious sweat drop
    _anxiousCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: false);
    _sweatDrop = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _anxiousCtrl,
        curve: const Interval(0.0, 0.7, curve: Curves.easeIn),
      ),
    );
    _blueTint = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _anxiousCtrl,
        curve: const Interval(0.0, 0.5, curve: Curves.easeInOut),
      ),
    );
  }

  @override
  void dispose() {
    _hoverCtrl.dispose();
    _happyBobCtrl.dispose();
    _stressShakeCtrl.dispose();
    _anxiousCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() => _hovered = true);
        _hoverCtrl.forward();
      },
      onExit: (_) {
        setState(() => _hovered = false);
        _hoverCtrl.reverse();
      },
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) {
          setState(() => _pressed = false);
          widget.onTap();
        },
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedScale(
          scale: _pressed ? 0.90 : 1.0,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Animated emoji container
              SizedBox(
                width: 80,
                height: 80,
                child: Center(child: _buildAnimatedEmoji()),
              ),
              const SizedBox(height: 12),
              Text(
                widget.label,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: _hovered ? FontWeight.w700 : FontWeight.w500,
                  color: AppTheme.textPrimary,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedEmoji() {
    switch (widget.moodType) {
      case MoodType.happy:
        return AnimatedBuilder(
          animation: Listenable.merge([_happyBob, _hoverScale]),
          builder: (_, __) => Transform.translate(
            offset: Offset(0, _happyBob.value),
            child: Transform.scale(
              scale: _hoverScale.value,
              child: Text(
                _hovered ? '😁' : '☺️',
                style: const TextStyle(fontSize: 64),
              ),
            ),
          ),
        );

      case MoodType.stressed:
        return AnimatedBuilder(
          animation: Listenable.merge([
            _stressShakeX,
            _stressScale,
            _hoverScale,
          ]),
          builder: (_, __) => Transform.translate(
            offset: Offset(_stressShakeX.value, 0),
            child: Transform.scale(
              scale: _stressScale.value * _hoverScale.value,
              child: Text(
                _hovered ? '😤' : '😠',
                style: const TextStyle(fontSize: 64),
              ),
            ),
          ),
        );

      case MoodType.anxious:
        return AnimatedBuilder(
          animation: Listenable.merge([_anxiousCtrl, _hoverScale]),
          builder: (_, __) {
            // Face gradually shifts blue
            final tintStrength = _blueTint.value * 0.35;
            // Sweat drop travels down
            final dropY = _sweatDrop.value * 24;
            final dropOpacity = _anxiousCtrl.value < 0.6
                ? _sweatDrop.value
                : (1.0 - (_anxiousCtrl.value - 0.6) / 0.4).clamp(0.0, 1.0);

            return Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Transform.scale(
                  scale: _hoverScale.value,
                  child: ColorFiltered(
                    colorFilter: ColorFilter.matrix([
                      1 - tintStrength,
                      0,
                      tintStrength * 0.3,
                      0,
                      0,
                      0,
                      1 - tintStrength,
                      tintStrength * 0.2,
                      0,
                      0,
                      tintStrength * 0.3,
                      tintStrength * 0.1,
                      1,
                      0,
                      0,
                      0,
                      0,
                      0,
                      1,
                      0,
                    ]),
                    child: const Text('😰', style: TextStyle(fontSize: 64)),
                  ),
                ),
                // Extra sweat drop
                Positioned(
                  right: 8,
                  top: 20 + dropY,
                  child: Opacity(
                    opacity: dropOpacity.clamp(0.0, 1.0),
                    child: Container(
                      width: 8,
                      height: 12,
                      decoration: BoxDecoration(
                        color: const Color(0xFF7BB8D4),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(4),
                          topRight: Radius.circular(4),
                          bottomLeft: Radius.circular(8),
                          bottomRight: Radius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
    }
  }
}
