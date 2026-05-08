import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/mood_provider.dart';
import '../utils/app_theme.dart';

class MoodSelectorWidget extends StatelessWidget {
  final List<Map<String, dynamic>> moods = const [
    {'label': 'Love',     'emoji': '😍', 'color': AppTheme.moodLove},
    {'label': 'Happy',    'emoji': '😊', 'color': AppTheme.moodHappy},
    {'label': 'Sad',      'emoji': '😢', 'color': AppTheme.moodSad},
    {'label': 'Depress',  'emoji': '😞', 'color': AppTheme.moodStressed},
    {'label': 'Worried',  'emoji': '😟', 'color': AppTheme.moodAnxious},
    {'label': 'Confused', 'emoji': '😵', 'color': AppTheme.moodConfused},
  ];

  const MoodSelectorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: moods.length,
        itemBuilder: (context, index) {
          final mood = moods[index];
          final label = mood['label'] as String;
          final emoji = mood['emoji'] as String;
          final color = mood['color'] as Color;

          return Consumer<MoodProvider>(
            builder: (context, moodProvider, child) {
              final isSelected = moodProvider.selectedMood == label;
              return _BounceEmoji(
                isSelected: isSelected,
                color: color,
                emoji: emoji,
                label: label,
                onTap: () => moodProvider.selectMood(label),
              );
            },
          );
        },
      ),
    );
  }
}

class _BounceEmoji extends StatefulWidget {
  final bool isSelected;
  final Color color;
  final String emoji;
  final String label;
  final VoidCallback onTap;

  const _BounceEmoji({
    required this.isSelected,
    required this.color,
    required this.emoji,
    required this.label,
    required this.onTap,
  });

  @override
  State<_BounceEmoji> createState() => _BounceEmojiState();
}

class _BounceEmojiState extends State<_BounceEmoji>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _bounce;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _bounce = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.25), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1.25, end: 0.9), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 0.9, end: 1.05), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1.05, end: 1.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void didUpdateWidget(covariant _BounceEmoji old) {
    super.didUpdateWidget(old);
    if (widget.isSelected && !old.isSelected) {
      _ctrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _bounce,
        builder: (_, child) => Transform.scale(scale: _bounce.value, child: child),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          margin: const EdgeInsets.only(right: 10),
          width: 68,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: widget.isSelected
                      ? widget.color.withValues(alpha: 0.15)
                      : AppTheme.surfaceDim,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: widget.isSelected
                        ? widget.color
                        : AppTheme.border,
                    width: widget.isSelected ? 2.5 : 1,
                  ),
                ),
                child: Center(
                  child: Text(widget.emoji, style: const TextStyle(fontSize: 24)),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                widget.label,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: widget.isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: widget.isSelected ? widget.color : AppTheme.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
