import '../models/meditation_session.dart';

class MeditationSessionsData {
  static const List<MeditationSession> sessions = [
    MeditationSession(
      id: 'stress_reset_5',
      title: 'Stress Reset',
      theme: 'stress',
      durationMinutes: 5,
      summary: 'A quick reset for tense moments during the day.',
      script: [
        'Sit comfortably and relax your jaw and shoulders.',
        'Inhale slowly for 4 counts and exhale for 6 counts.',
        'Notice one sensation in your body without judging it.',
        'Tell yourself: I can handle this one step at a time.',
      ],
    ),
    MeditationSession(
      id: 'anxiety_grounding_8',
      title: 'Anxiety Grounding',
      theme: 'anxiety',
      durationMinutes: 8,
      summary: 'Ground yourself when thoughts feel overwhelming.',
      script: [
        'Place both feet on the floor and feel the support.',
        'Name 5 things you see, 4 you feel, 3 you hear.',
        'Breathe in calm and breathe out tension.',
        'Repeat: This feeling is temporary, I am safe right now.',
      ],
    ),
    MeditationSession(
      id: 'sleep_unwind_10',
      title: 'Sleep Unwind',
      theme: 'sleep',
      durationMinutes: 10,
      summary: 'Unwind your body and mind before bedtime.',
      script: [
        'Dim lights and settle into a comfortable position.',
        'Relax each body area from head to toe.',
        'With each exhale, release one worry from today.',
        'Let your breathing become natural and effortless.',
      ],
    ),
    MeditationSession(
      id: 'focus_clarity_7',
      title: 'Focus Clarity',
      theme: 'focus',
      durationMinutes: 7,
      summary: 'Center attention before work or study.',
      script: [
        'Sit upright and choose one anchor: breath or sound.',
        'When your mind wanders, gently return to the anchor.',
        'Set a clear intention for the next task.',
        'Begin with one small, meaningful action.',
      ],
    ),
  ];
}
