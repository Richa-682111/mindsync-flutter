import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MoodProvider extends ChangeNotifier {
  String? _selectedMood;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get selectedMood => _selectedMood;

  // Stats
  int totalJournals = 0;
  int walkingSessions = 0;
  int meditationSessions = 0;
  int streakCount = 0;

  int happyCount = 0;
  int stressedCount = 0;
  int anxietyCount = 0;

  bool isLoadingStats = false;
  final List<String> unlockedMilestones = [];
  String? _pendingMilestone;
  String? get pendingMilestone => _pendingMilestone;

  // Reminder preferences
  bool journalReminderEnabled = false;
  bool meditationReminderEnabled = false;
  bool goalsReminderEnabled = false;
  int journalReminderHour = 20;
  int journalReminderMinute = 0;
  int meditationReminderHour = 8;
  int meditationReminderMinute = 0;
  int goalsReminderHour = 18;
  int goalsReminderMinute = 0;
  List<Map<String, dynamic>> customReminders = [];

  void selectMood(String mood) {
    if (_selectedMood != mood) {
      _selectedMood = mood;
      notifyListeners();
    }
  }

  Future<void> saveMood(String mood) async {
    _selectedMood = mood;
    notifyListeners();
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).collection('moods').add({
        'mood': mood,
        'timestamp': FieldValue.serverTimestamp(),
      });
      fetchUserStats(); // refresh stats
    }
  }

  Future<void> saveJournalEntry(String prompt, String answer) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).collection('journals').add({
        'prompt': prompt,
        'answer': answer,
        'timestamp': FieldValue.serverTimestamp(),
      });
      fetchUserStats();
    }
  }

  Future<void> deleteJournalEntry(String journalId) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('journals')
          .doc(journalId)
          .delete();
      fetchUserStats();
    }
  }

  Future<void> saveActivity(String activityType) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).collection('activities').add({
        'type': activityType,
        'timestamp': FieldValue.serverTimestamp(),
      });
      fetchUserStats();
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> goalsStream() {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();
    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('goals')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<void> addGoal(String title) async {
    final user = _auth.currentUser;
    if (user == null || title.trim().isEmpty) return;
    await _firestore.collection('users').doc(user.uid).collection('goals').add({
      'title': title.trim(),
      'isCompleted': false,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateGoal(String goalId, String title) async {
    final user = _auth.currentUser;
    if (user == null || title.trim().isEmpty) return;
    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('goals')
        .doc(goalId)
        .update({
      'title': title.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> toggleGoalCompletion(String goalId, bool value) async {
    final user = _auth.currentUser;
    if (user == null) return;
    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('goals')
        .doc(goalId)
        .update({
      'isCompleted': value,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteGoal(String goalId) async {
    final user = _auth.currentUser;
    if (user == null) return;
    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('goals')
        .doc(goalId)
        .delete();
  }

  Future<void> loadReminderPreferences() async {
    final user = _auth.currentUser;
    if (user == null) return;
    final snap = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('settings')
        .doc('reminders')
        .get();
    final data = snap.data();
    if (data == null) return;
    journalReminderEnabled = (data['journalEnabled'] ?? false) as bool;
    meditationReminderEnabled = (data['meditationEnabled'] ?? false) as bool;
    goalsReminderEnabled = (data['goalsEnabled'] ?? false) as bool;
    journalReminderHour = (data['journalHour'] ?? 20) as int;
    journalReminderMinute = (data['journalMinute'] ?? 0) as int;
    meditationReminderHour = (data['meditationHour'] ?? 8) as int;
    meditationReminderMinute = (data['meditationMinute'] ?? 0) as int;
    goalsReminderHour = (data['goalsHour'] ?? 18) as int;
    goalsReminderMinute = (data['goalsMinute'] ?? 0) as int;
    final rawCustom = data['customReminders'];
    if (rawCustom is List) {
      customReminders = rawCustom
          .whereType<Map>()
          .map((item) => {
                'title': (item['title'] ?? '').toString(),
                'enabled': (item['enabled'] ?? false) as bool,
                'hour': (item['hour'] ?? 9) as int,
                'minute': (item['minute'] ?? 0) as int,
              })
          .where((item) => (item['title'] as String).trim().isNotEmpty)
          .toList();
    } else {
      customReminders = [];
    }
    notifyListeners();
  }

  Future<void> saveReminderPreferences() async {
    final user = _auth.currentUser;
    if (user == null) return;
    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('settings')
        .doc('reminders')
        .set({
      'journalEnabled': journalReminderEnabled,
      'meditationEnabled': meditationReminderEnabled,
      'goalsEnabled': goalsReminderEnabled,
      'journalHour': journalReminderHour,
      'journalMinute': journalReminderMinute,
      'meditationHour': meditationReminderHour,
      'meditationMinute': meditationReminderMinute,
      'goalsHour': goalsReminderHour,
      'goalsMinute': goalsReminderMinute,
      'customReminders': customReminders,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  void addCustomReminder(String title) {
    final trimmed = title.trim();
    if (trimmed.isEmpty) return;
    customReminders.add({
      'title': trimmed,
      'enabled': true,
      'hour': 9,
      'minute': 0,
    });
    notifyListeners();
  }

  void removeCustomReminderAt(int index) {
    if (index < 0 || index >= customReminders.length) return;
    customReminders.removeAt(index);
    notifyListeners();
  }

  void toggleCustomReminderAt(int index, bool value) {
    if (index < 0 || index >= customReminders.length) return;
    customReminders[index]['enabled'] = value;
    notifyListeners();
  }

  void setCustomReminderTimeAt(int index, int hour, int minute) {
    if (index < 0 || index >= customReminders.length) return;
    customReminders[index]['hour'] = hour;
    customReminders[index]['minute'] = minute;
    notifyListeners();
  }

  Future<void> fetchUserStats() async {
    final user = _auth.currentUser;
    if (user == null) return;

    isLoadingStats = true;
    notifyListeners();

    try {
      final userDoc = _firestore.collection('users').doc(user.uid);

      // Fetch Journals
      final journals = await userDoc.collection('journals').get();
      totalJournals = journals.docs.length;

      // Fetch Activities
      final activities = await userDoc.collection('activities').get();
      walkingSessions = 0;
      meditationSessions = 0;
      for (var doc in activities.docs) {
        if (doc.data()['type'] == 'walking') walkingSessions++;
        if (doc.data()['type'] == 'meditation') meditationSessions++;
      }

      // Fetch Moods
      final moods = await userDoc.collection('moods').orderBy('timestamp', descending: true).get();
      happyCount = 0;
      stressedCount = 0;
      anxietyCount = 0;
      
      DateTime? lastDate;
      int currentStreak = 0;

      for (var doc in moods.docs) {
        final mood = doc.data()['mood'];
        if (mood == 'Happy') happyCount++;
        if (mood == 'Stressed') stressedCount++;
        if (mood == 'Anxiety') anxietyCount++;

        // Streak calculation
        if (doc.data()['timestamp'] != null) {
          final timestamp = doc.data()['timestamp'] as Timestamp;
          final date = timestamp.toDate();
          final justDate = DateTime(date.year, date.month, date.day);
          
          if (lastDate == null) {
            currentStreak = 1;
            lastDate = justDate;
          } else {
            final difference = lastDate.difference(justDate).inDays;
            if (difference == 1) {
              currentStreak++;
              lastDate = justDate;
            } else if (difference > 1) {
              // Streak broken
              // don't break if difference is 0 (same day)
            }
          }
        }
      }
      
      // If the last date was more than 1 day ago from today, streak is 0
      if (lastDate != null) {
        final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
        if (today.difference(lastDate).inDays > 1) {
          currentStreak = 0;
        }
      }
      
      streakCount = currentStreak;

      await _checkAndUnlockMilestones(userDoc);

      final milestones = await userDoc.collection('milestones').get();
      unlockedMilestones
        ..clear()
        ..addAll(
          milestones.docs
              .map((d) => (d.data()['title'] ?? '').toString())
              .where((t) => t.isNotEmpty),
        );

    } catch (e) {
      print('Error fetching stats: $e');
    }

    isLoadingStats = false;
    notifyListeners();
  }

  String? consumePendingMilestone() {
    final value = _pendingMilestone;
    _pendingMilestone = null;
    return value;
  }

  Future<void> _checkAndUnlockMilestones(
    DocumentReference<Map<String, dynamic>> userDoc,
  ) async {
    final rules = <Map<String, dynamic>>[
      {
        'id': 'first_goal_completed',
        'title': 'First Goal Completed',
        'unlocked': false,
      },
      {
        'id': 'three_day_streak',
        'title': '3-Day Streak',
        'unlocked': streakCount >= 3,
      },
      {
        'id': 'five_journals',
        'title': '5 Journal Entries',
        'unlocked': totalJournals >= 5,
      },
      {
        'id': 'five_meditations',
        'title': '5 Meditation Sessions',
        'unlocked': meditationSessions >= 5,
      },
    ];

    try {
      final goalsSnapshot = await userDoc
          .collection('goals')
          .where('isCompleted', isEqualTo: true)
          .limit(1)
          .get();
      final firstGoalDone = goalsSnapshot.docs.isNotEmpty;
      rules[0]['unlocked'] = firstGoalDone;
    } catch (_) {
      // Keep default false if goals collection isn't available.
    }

    for (final rule in rules) {
      if (rule['unlocked'] != true) continue;
      final id = rule['id'] as String;
      final title = rule['title'] as String;
      final ref = userDoc.collection('milestones').doc(id);
      final existing = await ref.get();
      if (!existing.exists) {
        await ref.set({
          'title': title,
          'unlockedAt': FieldValue.serverTimestamp(),
        });
        _pendingMilestone = title;
      }
    }
  }
}
