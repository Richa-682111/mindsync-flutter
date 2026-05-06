import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../utils/app_theme.dart';
import '../providers/mood_provider.dart';
import '../providers/auth_provider.dart';
import '../services/gemini_service.dart';

class ProfileDashboardScreen extends StatefulWidget {
  const ProfileDashboardScreen({super.key});

  @override
  State<ProfileDashboardScreen> createState() => _ProfileDashboardScreenState();
}

class _ProfileDashboardScreenState extends State<ProfileDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MoodProvider>().fetchUserStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.surfaceDim,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back_ios_new, size: 14),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.surfaceDim,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_outlined, size: 14, color: AppTheme.textPrimary),
                  const SizedBox(width: 6),
                  Text(
                    DateFormat('dd MMM yyyy').format(DateTime.now()),
                    style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              onPressed: () {
                context.read<AuthProvider>().signOut();
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              icon: const Icon(Icons.logout, size: 20),
            ),
          ),
        ],
      ),
      body: Container(
        color: AppTheme.mainBackgroundColor,
        child: SafeArea(
          child: Consumer<MoodProvider>(
            builder: (context, moodProvider, child) {
              if (moodProvider.isLoadingStats) {
                return const Center(child: CircularProgressIndicator(color: AppTheme.accent, strokeWidth: 2));
              }

              final totalEntries = moodProvider.happyCount + moodProvider.stressedCount + moodProvider.anxietyCount;
              final happyPercent = totalEntries > 0 ? ((moodProvider.happyCount / totalEntries) * 100).toInt() : 0;

              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                child: Column(
                  children: [
                    // ── Hero Section (Mindfulness Heart) ──
                    _buildHeroSection(happyPercent),
                    const SizedBox(height: 40),

                    // ── Mood Statistic Card ──
                    _buildMoodStatisticCard(moodProvider, totalEntries),
                    const SizedBox(height: 24),

                    // ── Overview Stats ──
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Overview', style: GoogleFonts.playfairDisplay(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _StatCard(title: 'Streak', value: '${moodProvider.streakCount}', unit: 'days', icon: Icons.local_fire_department_outlined, iconColor: AppTheme.warmTone, bgColor: AppTheme.warmSoft)),
                        const SizedBox(width: 12),
                        Expanded(child: _StatCard(title: 'Journals', value: '${moodProvider.totalJournals}', unit: 'entries', icon: Icons.book_outlined, iconColor: AppTheme.accent, bgColor: AppTheme.accentSoft)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _StatCard(title: 'Walks', value: '${moodProvider.walkingSessions}', unit: 'sessions', icon: Icons.directions_walk_outlined, iconColor: AppTheme.positive, bgColor: AppTheme.positiveSoft)),
                        const SizedBox(width: 12),
                        Expanded(child: _StatCard(title: 'Meditation', value: '${moodProvider.meditationSessions}', unit: 'sessions', icon: Icons.self_improvement_outlined, iconColor: AppTheme.moodAnxious, bgColor: AppTheme.warmSoft)),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  String _dominantMood(MoodProvider provider) {
    final entries = <String, int>{
      'Happy': provider.happyCount,
      'Stressed': provider.stressedCount,
      'Anxiety': provider.anxietyCount,
    };
    final sorted = entries.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top = sorted.first;
    return top.value > 0 ? top.key : (provider.selectedMood ?? 'Anxiety');
  }

  List<String> _fallbackTips(String mood) {
    switch (mood) {
      case 'Happy':
        return const [
          'Capture one win from today in your journal.',
          'Share your good mood with one supportive person.',
          'Take a 10-minute mindful walk outdoors.',
          'Listen to one song that keeps your energy balanced.',
          'Set one small goal for tomorrow before sleep.',
        ];
      case 'Stressed':
        return const [
          'Do one 4-7-8 breathing cycle for two minutes.',
          'Break your next task into a 10-minute first step.',
          'Stretch your shoulders and neck for three minutes.',
          'Drink water, then take a short no-phone walk.',
          'Write down one thing you can control right now.',
        ];
      default:
        return const [
          'Name five things you can see and hear around you.',
          'Place your hand on your chest and breathe slowly.',
          'Write one fear, then one realistic counter-thought.',
          'Reduce stimulation: dim lights and silence notifications.',
          'Repeat a calming phrase for one focused minute.',
        ];
    }
  }

  Future<void> _showMoodBoosterTips(MoodProvider provider) async {
    final mood = _dominantMood(provider);
    List<String>? tips;
    try {
      tips = await GeminiService.generateMoodBoosterTips(mood: mood);
    } catch (_) {
      tips = null;
    }

    if (!mounted) return;
    final resolvedTips = tips ?? _fallbackTips(mood);

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
          decoration: BoxDecoration(
            color: AppTheme.canvas,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppTheme.border),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$mood Mood Boosters',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              ...resolvedTips.map(
                (tip) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 6),
                        child: Icon(
                          Icons.circle,
                          size: 7,
                          color: AppTheme.accent,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          tip,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: AppTheme.textSecondary,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeroSection(int mainPercent) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned(
          top: 0,
          child: Opacity(
            opacity: 0.08,
            child: Text(
              'Mindfulness',
              style: GoogleFonts.playfairDisplay(
                fontSize: 60,
                fontWeight: FontWeight.bold,
                color: AppTheme.accent,
                letterSpacing: 1,
              ),
            ),
          ),
        ),
        Column(
          children: [
            const SizedBox(height: 20),
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Color(0xFFE8B6D8), Color(0xFFB46E96)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ).createShader(bounds),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(Icons.favorite, size: 160, color: Colors.white),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Text(
                      '$mainPercent%',
                      style: GoogleFonts.inter(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text('Keep going!', style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(color: AppTheme.accentSoft, shape: BoxShape.circle),
                  child: const Icon(Icons.military_tech, size: 14, color: AppTheme.accent),
                ),
                const SizedBox(width: 8),
                Text.rich(
                  TextSpan(
                    text: 'Statistics ',
                    style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textSecondary),
                    children: [
                      TextSpan(text: 'up 15%', style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMoodStatisticCard(MoodProvider provider, int total) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Mood Statistic', style: GoogleFonts.playfairDisplay(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                  const SizedBox(height: 4),
                  Text('Check your mood everytime', style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textSecondary)),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: AppTheme.surfaceDim, shape: BoxShape.circle),
                child: const Icon(Icons.more_vert, size: 18, color: AppTheme.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              SizedBox(
                height: 150,
                width: 150,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    PieChart(
                      PieChartData(
                        sectionsSpace: 6,
                        centerSpaceRadius: 48,
                        startDegreeOffset: -90,
                        sections: [
                          PieChartSectionData(
                            color: AppTheme.moodHappy,
                            value: provider.happyCount.toDouble() == 0 ? 0.1 : provider.happyCount.toDouble(),
                            radius: 22,
                            showTitle: true,
                            title: provider.happyCount > 0 ? '${((provider.happyCount/total)*100).toInt()}%' : '',
                            titleStyle: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          PieChartSectionData(
                            color: AppTheme.moodStressed,
                            value: provider.stressedCount.toDouble() == 0 ? 0.1 : provider.stressedCount.toDouble(),
                            radius: 18,
                            showTitle: true,
                            title: provider.stressedCount > 0 ? '${((provider.stressedCount/total)*100).toInt()}%' : '',
                            titleStyle: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          PieChartSectionData(
                            color: AppTheme.moodAnxious,
                            value: provider.anxietyCount.toDouble() == 0 ? 0.1 : provider.anxietyCount.toDouble(),
                            radius: 14,
                            showTitle: true,
                            title: provider.anxietyCount > 0 ? '${((provider.anxietyCount/total)*100).toInt()}%' : '',
                            titleStyle: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ]
                      )
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('$total', style: GoogleFonts.playfairDisplay(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                        Text('Total', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _legendItem(AppTheme.moodHappy, 'Happy'),
                    const SizedBox(height: 16),
                    _legendItem(AppTheme.moodStressed, 'Stressed'),
                    const SizedBox(height: 16),
                    _legendItem(AppTheme.moodAnxious, 'Anxious'),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.only(top: 24),
            decoration: BoxDecoration(border: Border(top: BorderSide(color: AppTheme.border))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Boost your mood', style: GoogleFonts.playfairDisplay(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                    const SizedBox(height: 4),
                    Text('Boost your mood in many ways', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary)),
                  ],
                ),
                ElevatedButton(
                  onPressed: () => _showMoodBoosterTips(provider),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accent,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: const Text('Learn more', style: TextStyle(fontSize: 13)),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 10),
        Text(label, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: AppTheme.textPrimary)),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String unit;
  final IconData icon;
  final Color iconColor;
  final Color bgColor;

  const _StatCard({required this.title, required this.value, required this.unit, required this.icon, required this.iconColor, required this.bgColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white, width: 1.5),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(height: 12),
          Text(title, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: AppTheme.textSecondary)),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(value, style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w700, color: AppTheme.textPrimary, letterSpacing: -0.5)),
              const SizedBox(width: 4),
              Text(unit, style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textMuted)),
            ],
          ),
        ],
      ),
    );
  }
}
