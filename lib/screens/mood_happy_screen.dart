import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/gemini_service.dart';
import '../utils/app_theme.dart';
import '../widgets/journal_card_widget.dart';
import '../widgets/meditation_timer_widget.dart';

class MoodHappyScreen extends StatefulWidget {
  const MoodHappyScreen({super.key});

  @override
  State<MoodHappyScreen> createState() => _MoodHappyScreenState();
}

class _MoodHappyScreenState extends State<MoodHappyScreen> {
  bool _isLoadingGoals = false;
  List<String> _dailyGoals = const [
    'Drink 2L of water',
    'Read 10 pages',
    'Meditate for 5 mins',
    'Get 10 minutes of sunlight',
  ];

  @override
  void initState() {
    super.initState();
    _loadAiDailyGoals();
  }

  Future<void> _loadAiDailyGoals() async {
    setState(() => _isLoadingGoals = true);
    try {
      final goals = await GeminiService.generateDailyGoals(mood: 'Happy');
      if (!mounted) return;
      if (goals != null && goals.isNotEmpty) {
        setState(() => _dailyGoals = goals);
      }
    } catch (_) {
      // Keep fallback goals.
    } finally {
      if (mounted) setState(() => _isLoadingGoals = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Feeling Happy'),
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: Container(
        color: AppTheme.canvas,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppTheme.positiveSoft,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppTheme.positive.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppTheme.positive.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.wb_sunny_outlined,
                          color: AppTheme.positive,
                          size: 22,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'You are doing great.',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Keep this positive momentum going.',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                _Label(text: 'Reflect on today'),
                const SizedBox(height: 12),
                const JournalCardWidget(prompt: 'What made today special?'),
                const SizedBox(height: 32),
                _Label(text: 'Meditation'),
                const SizedBox(height: 12),
                const MeditationTimerWidget(),
                const SizedBox(height: 32),
                Row(
                  children: [
                    _Label(text: 'Daily goals'),
                    const SizedBox(width: 8),
                    if (_isLoadingGoals)
                      const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppTheme.accent,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                ..._dailyGoals.map((goal) => _GoalTile(title: goal)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label({required this.text});
  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: AppTheme.textMuted,
        letterSpacing: 0.8,
      ),
    );
  }
}

class _GoalTile extends StatefulWidget {
  final String title;
  const _GoalTile({required this.title});

  @override
  State<_GoalTile> createState() => _GoalTileState();
}

class _GoalTileState extends State<_GoalTile> {
  bool _isDone = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: _isDone ? AppTheme.positiveSoft : AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isDone
              ? AppTheme.positive.withValues(alpha: 0.4)
              : AppTheme.border,
        ),
      ),
      child: CheckboxListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        title: Text(
          widget.title,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: _isDone ? AppTheme.textSecondary : AppTheme.textPrimary,
            decoration: _isDone ? TextDecoration.lineThrough : null,
          ),
        ),
        value: _isDone,
        onChanged: (val) => setState(() => _isDone = val ?? false),
        activeColor: AppTheme.positive,
        checkColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
    );
  }
}
