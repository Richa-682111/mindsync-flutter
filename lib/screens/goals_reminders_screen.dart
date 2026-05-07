import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/mood_provider.dart';
import '../services/notification_service.dart';
import '../utils/app_theme.dart';

class GoalsRemindersScreen extends StatefulWidget {
  const GoalsRemindersScreen({super.key});

  @override
  State<GoalsRemindersScreen> createState() => _GoalsRemindersScreenState();
}

class _GoalsRemindersScreenState extends State<GoalsRemindersScreen> {
  final TextEditingController _goalCtrl = TextEditingController();

  void _showActionFeedback(Object error) {
    final text = error.toString().toLowerCase();
    final isNetworkIssue = text.contains('network') ||
        text.contains('unavailable') ||
        text.contains('socket') ||
        text.contains('timed out');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isNetworkIssue
              ? 'No internet connection. Please try again.'
              : 'Something went wrong. Please try again.',
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MoodProvider>().loadReminderPreferences();
    });
  }

  @override
  void dispose() {
    _goalCtrl.dispose();
    super.dispose();
  }

  Future<void> _addGoal() async {
    final title = _goalCtrl.text.trim();
    if (title.isEmpty) return;
    try {
      await context.read<MoodProvider>().addGoal(title);
      _goalCtrl.clear();
    } catch (e) {
      _showActionFeedback(e);
    }
  }

  Future<void> _editGoal(String id, String initial) async {
    final ctrl = TextEditingController(text: initial);
    final updated = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit Goal'),
        content: TextField(controller: ctrl, autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, ctrl.text.trim()), child: const Text('Save')),
        ],
      ),
    );
    if (updated == null || updated.isEmpty) return;
    try {
      await context.read<MoodProvider>().updateGoal(id, updated);
    } catch (e) {
      _showActionFeedback(e);
    }
  }

  Future<void> _pickTime({
    required int hour,
    required int minute,
    required void Function(TimeOfDay) onChanged,
  }) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: hour, minute: minute),
    );
    if (picked != null) onChanged(picked);
  }

  Future<void> _applyNotifications(MoodProvider provider) async {
    if (provider.journalReminderEnabled) {
      await NotificationService.scheduleDaily(
        id: 1001,
        title: 'Journal Check-in',
        body: 'Take 2 minutes to reflect on your day.',
        hour: provider.journalReminderHour,
        minute: provider.journalReminderMinute,
      );
    } else {
      await NotificationService.cancel(1001);
    }

    if (provider.meditationReminderEnabled) {
      await NotificationService.scheduleDaily(
        id: 1002,
        title: 'Meditation Reminder',
        body: 'A short mindful session can reset your day.',
        hour: provider.meditationReminderHour,
        minute: provider.meditationReminderMinute,
      );
    } else {
      await NotificationService.cancel(1002);
    }

    if (provider.goalsReminderEnabled) {
      await NotificationService.scheduleDaily(
        id: 1003,
        title: 'Goals Check-in',
        body: 'Review and complete one goal today.',
        hour: provider.goalsReminderHour,
        minute: provider.goalsReminderMinute,
      );
    } else {
      await NotificationService.cancel(1003);
    }
  }

  @override
  Widget build(BuildContext context) {
    final moodProvider = context.watch<MoodProvider>();

    return Scaffold(
      backgroundColor: AppTheme.canvas,
      appBar: AppBar(
        title: const Text('Goals & Reminders'),
        backgroundColor: AppTheme.canvas,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Goals',
                style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _goalCtrl,
                      decoration: const InputDecoration(hintText: 'Add a new goal'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(onPressed: _addGoal, child: const Text('Add')),
                ],
              ),
              const SizedBox(height: 12),
              StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: moodProvider.goalsStream(),
                builder: (context, snapshot) {
                  final docs = snapshot.data?.docs ?? const [];
                  if (docs.isEmpty) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceDim,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'No goals yet. Add your first goal.',
                        style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textSecondary),
                      ),
                    );
                  }
                  return Column(
                    children: docs.map((doc) {
                      final data = doc.data();
                      final title = (data['title'] ?? '').toString();
                      final done = (data['isCompleted'] ?? false) as bool;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: AppTheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.border),
                        ),
                        child: ListTile(
                          leading: Checkbox(
                            value: done,
                            onChanged: (v) => moodProvider.toggleGoalCompletion(doc.id, v ?? false),
                          ),
                          title: Text(
                            title,
                            style: GoogleFonts.inter(
                              color: AppTheme.textPrimary,
                              decoration: done ? TextDecoration.lineThrough : null,
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () => _editGoal(doc.id, title),
                                icon: const Icon(Icons.edit_outlined, size: 18),
                              ),
                              IconButton(
                                onPressed: () => moodProvider.deleteGoal(doc.id),
                                icon: const Icon(Icons.delete_outline, size: 18),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
              const SizedBox(height: 22),
              Text(
                'Reminders',
                style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
              ),
              const SizedBox(height: 10),
              _ReminderTile(
                title: 'Journal Reminder',
                enabled: moodProvider.journalReminderEnabled,
                timeText: _timeText(moodProvider.journalReminderHour, moodProvider.journalReminderMinute),
                onToggle: (v) => setState(() => moodProvider.journalReminderEnabled = v),
                onPickTime: () => _pickTime(
                  hour: moodProvider.journalReminderHour,
                  minute: moodProvider.journalReminderMinute,
                  onChanged: (t) => setState(() {
                    moodProvider.journalReminderHour = t.hour;
                    moodProvider.journalReminderMinute = t.minute;
                  }),
                ),
              ),
              _ReminderTile(
                title: 'Meditation Reminder',
                enabled: moodProvider.meditationReminderEnabled,
                timeText: _timeText(moodProvider.meditationReminderHour, moodProvider.meditationReminderMinute),
                onToggle: (v) => setState(() => moodProvider.meditationReminderEnabled = v),
                onPickTime: () => _pickTime(
                  hour: moodProvider.meditationReminderHour,
                  minute: moodProvider.meditationReminderMinute,
                  onChanged: (t) => setState(() {
                    moodProvider.meditationReminderHour = t.hour;
                    moodProvider.meditationReminderMinute = t.minute;
                  }),
                ),
              ),
              _ReminderTile(
                title: 'Goals Reminder',
                enabled: moodProvider.goalsReminderEnabled,
                timeText: _timeText(moodProvider.goalsReminderHour, moodProvider.goalsReminderMinute),
                onToggle: (v) => setState(() => moodProvider.goalsReminderEnabled = v),
                onPickTime: () => _pickTime(
                  hour: moodProvider.goalsReminderHour,
                  minute: moodProvider.goalsReminderMinute,
                  onChanged: (t) => setState(() {
                    moodProvider.goalsReminderHour = t.hour;
                    moodProvider.goalsReminderMinute = t.minute;
                  }),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    try {
                      await moodProvider.saveReminderPreferences();
                      await _applyNotifications(moodProvider);
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Goals and reminders saved.')),
                      );
                    } catch (e) {
                      if (!mounted) return;
                      _showActionFeedback(e);
                    }
                  },
                  child: const Text('Save Reminder Settings'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _timeText(int hour, int minute) {
    final h = hour % 12 == 0 ? 12 : hour % 12;
    final m = minute.toString().padLeft(2, '0');
    final ap = hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $ap';
  }
}

class _ReminderTile extends StatelessWidget {
  const _ReminderTile({
    required this.title,
    required this.enabled,
    required this.timeText,
    required this.onToggle,
    required this.onPickTime,
  });

  final String title;
  final bool enabled;
  final String timeText;
  final ValueChanged<bool> onToggle;
  final VoidCallback onPickTime;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(timeText, style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textMuted)),
              ],
            ),
          ),
          TextButton(onPressed: onPickTime, child: const Text('Time')),
          Switch(value: enabled, onChanged: onToggle),
        ],
      ),
    );
  }
}
