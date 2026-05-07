import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_theme.dart';

class MentalHealthResourcesScreen extends StatelessWidget {
  const MentalHealthResourcesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.canvas,
      appBar: AppBar(
        title: const Text('Help & Resources'),
        backgroundColor: AppTheme.canvas,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: const [
            _ResourceSection(
              title: 'Crisis Support',
              items: [
                _ResourceItem(
                  title: '988 Suicide & Crisis Lifeline (US)',
                  detail: 'Call or text 988 (24/7 confidential support).',
                ),
                _ResourceItem(
                  title: 'Emergency Services',
                  detail: 'If immediate danger exists, call local emergency services.',
                ),
              ],
            ),
            SizedBox(height: 16),
            _ResourceSection(
              title: 'Self-Help',
              items: [
                _ResourceItem(
                  title: 'Grounding Checklist',
                  detail: 'Use 5-4-3-2-1 sensory grounding when overwhelmed.',
                ),
                _ResourceItem(
                  title: 'Sleep Hygiene Basics',
                  detail: 'Same bedtime, low light, no screens before sleep.',
                ),
              ],
            ),
            SizedBox(height: 16),
            _ResourceSection(
              title: 'Therapy Finder',
              items: [
                _ResourceItem(
                  title: 'Ask Your Primary Care Provider',
                  detail: 'Request licensed therapist referrals covered by insurance.',
                ),
                _ResourceItem(
                  title: 'Community Mental Health Centers',
                  detail: 'Look up local centers for affordable counseling services.',
                ),
              ],
            ),
            SizedBox(height: 16),
            _ResourceSection(
              title: 'Psychoeducation',
              items: [
                _ResourceItem(
                  title: 'Cognitive Distortions',
                  detail: 'Learn common thought patterns to improve reframing.',
                ),
                _ResourceItem(
                  title: 'Stress Response',
                  detail: 'Understand fight/flight and how breathing helps regulate.',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ResourceSection extends StatelessWidget {
  const _ResourceSection({required this.title, required this.items});

  final String title;
  final List<_ResourceItem> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        ...items.map(
          (item) => Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.detail,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ResourceItem {
  const _ResourceItem({required this.title, required this.detail});

  final String title;
  final String detail;
}
