import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_theme.dart';
import '../providers/mood_provider.dart';
import '../providers/auth_provider.dart';

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
      backgroundColor: AppTheme.canvas,
      appBar: AppBar(
        title: const Text('Your Progress'),
        backgroundColor: AppTheme.canvas,
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton.icon(
              onPressed: () {
                context.read<AuthProvider>().signOut();
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              icon: const Icon(Icons.logout, size: 16),
              label: const Text('Sign out'),
              style: TextButton.styleFrom(foregroundColor: AppTheme.textSecondary),
            ),
          ),
        ],
      ),
      body: Consumer<MoodProvider>(
        builder: (context, moodProvider, child) {
          if (moodProvider.isLoadingStats) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.accent, strokeWidth: 2),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Stat grid ──
                _sectionLabel('Overview'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        title: 'Streak',
                        value: '${moodProvider.streakCount}',
                        unit: 'days',
                        icon: Icons.local_fire_department_outlined,
                        iconColor: AppTheme.warmTone,
                        bgColor: AppTheme.warmSoft,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        title: 'Journals',
                        value: '${moodProvider.totalJournals}',
                        unit: 'entries',
                        icon: Icons.book_outlined,
                        iconColor: AppTheme.accent,
                        bgColor: AppTheme.accentSoft,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        title: 'Walks',
                        value: '${moodProvider.walkingSessions}',
                        unit: 'sessions',
                        icon: Icons.directions_walk_outlined,
                        iconColor: AppTheme.positive,
                        bgColor: AppTheme.positiveSoft,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        title: 'Meditation',
                        value: '${moodProvider.meditationSessions}',
                        unit: 'sessions',
                        icon: Icons.self_improvement_outlined,
                        iconColor: AppTheme.moodAnxious,
                        bgColor: const Color(0xFFE8EFF4),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // ── Mood chart ──
                _sectionLabel('Mood overview'),
                const SizedBox(height: 12),
                Container(
                  height: 200,
                  padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: [
                        moodProvider.happyCount,
                        moodProvider.stressedCount,
                        moodProvider.anxietyCount
                      ].reduce((a, b) => a > b ? a : b).toDouble() + 1,
                      barTouchData: BarTouchData(enabled: false),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 28,
                            getTitlesWidget: (double value, TitleMeta meta) {
                              final labels = ['Happy', 'Stressed', 'Anxious'];
                              final style = GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.textMuted,
                              );
                              final idx = value.toInt();
                              if (idx < 0 || idx >= labels.length) return const SizedBox();
                              return SideTitleWidget(
                                axisSide: meta.axisSide,
                                child: Text(labels[idx], style: style),
                              );
                            },
                          ),
                        ),
                        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: false),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (_) => FlLine(
                          color: AppTheme.border,
                          strokeWidth: 1,
                        ),
                      ),
                      barGroups: [
                        _makeBar(0, moodProvider.happyCount.toDouble(), AppTheme.moodHappy),
                        _makeBar(1, moodProvider.stressedCount.toDouble(), AppTheme.moodStressed),
                        _makeBar(2, moodProvider.anxietyCount.toDouble(), AppTheme.moodAnxious),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // ── Insight ──
                _sectionLabel('Insight'),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppTheme.accentSoft,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.lightbulb_outline, color: AppTheme.accent, size: 18),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          moodProvider.stressedCount > moodProvider.happyCount
                              ? 'You\'ve reported feeling stressed quite a bit. Consider adding more meditation sessions to your routine.'
                              : 'You\'re doing great! Keep up the good mood and maintain your current streak.',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: AppTheme.textSecondary,
                            height: 1.55,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _sectionLabel(String text) {
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

  BarChartGroupData _makeBar(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: 28,
          borderRadius: BorderRadius.circular(6),
        ),
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

  const _StatCard({
    required this.title,
    required this.value,
    required this.unit,
    required this.icon,
    required this.iconColor,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textMuted,
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      value,
                      style: GoogleFonts.inter(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(width: 3),
                    Text(
                      unit,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
