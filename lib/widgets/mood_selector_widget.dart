import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/mood_provider.dart';
import '../utils/app_theme.dart';

class MoodSelectorWidget extends StatelessWidget {
  final List<Map<String, dynamic>> moods = const [
    {'label': 'Happy',   'emoji': '😊', 'color': AppTheme.moodHappy},
    {'label': 'Calm',    'emoji': '😌', 'color': AppTheme.accent},
    {'label': 'Stressed','emoji': '😤', 'color': AppTheme.moodStressed},
    {'label': 'Sad',     'emoji': '😢', 'color': AppTheme.moodAnxious},
    {'label': 'Angry',   'emoji': '😠', 'color': Color(0xFFAF8D8D)},
  ];

  MoodSelectorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
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
              return GestureDetector(
                onTap: () => moodProvider.selectMood(label),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  margin: const EdgeInsets.only(right: 10),
                  width: 76,
                  decoration: BoxDecoration(
                    color: isSelected ? color.withValues(alpha: 0.12) : AppTheme.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected ? color.withValues(alpha: 0.6) : AppTheme.border,
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(emoji, style: const TextStyle(fontSize: 24)),
                      const SizedBox(height: 4),
                      Text(
                        label,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: isSelected ? color : AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
