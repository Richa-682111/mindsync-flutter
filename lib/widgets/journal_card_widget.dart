import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_theme.dart';
import '../providers/mood_provider.dart';

class JournalCardWidget extends StatefulWidget {
  final String prompt;

  const JournalCardWidget({
    super.key,
    required this.prompt,
  });

  @override
  State<JournalCardWidget> createState() => _JournalCardWidgetState();
}

class _JournalCardWidgetState extends State<JournalCardWidget> {
  final TextEditingController _controller = TextEditingController();
  bool _isExpanded = false;
  bool _isSaved = false;

  void _saveEntry() {
    if (_controller.text.trim().isEmpty) return;
    context.read<MoodProvider>().saveJournalEntry(
          widget.prompt,
          _controller.text.trim(),
        );
    setState(() {
      _isSaved = true;
      _isExpanded = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Journal entry saved.'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: AppTheme.textPrimary,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isSaved) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.positiveSoft,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.positive.withValues(alpha: 0.35)),
        ),
        child: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: AppTheme.positive, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Entry saved. Great job reflecting!',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isExpanded ? AppTheme.accent.withValues(alpha: 0.5) : AppTheme.border,
        ),
      ),
      child: InkWell(
        onTap: () {
          if (!_isExpanded) setState(() => _isExpanded = true);
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppTheme.accentSoft,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.edit_note, color: AppTheme.accent, size: 17),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Daily Reflection',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                widget.prompt,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  color: AppTheme.textSecondary,
                  height: 1.5,
                ),
              ),
              // Expanded input
              if (_isExpanded) ...[
                const SizedBox(height: 16),
                TextField(
                  controller: _controller,
                  maxLines: 4,
                  autofocus: true,
                  style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textPrimary),
                  decoration: const InputDecoration(
                    hintText: 'Write your thoughts here...',
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => setState(() => _isExpanded = false),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _saveEntry,
                      child: const Text('Save'),
                    ),
                  ],
                ),
              ] else ...[
                const SizedBox(height: 12),
                Text(
                  'Tap to write...',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppTheme.accent,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
