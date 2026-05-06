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

    } catch (e) {
      print('Error fetching stats: $e');
    }

    isLoadingStats = false;
    notifyListeners();
  }
}
