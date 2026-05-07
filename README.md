# MindSync

MindSync is a Flutter mental wellness app focused on short, practical daily support:
mood check-ins, guided meditation, journaling, goals, reminders, and progress tracking.

## Core Features

- Email/password authentication with Firebase Auth
- Mood tracking with Firestore persistence
- Guided meditation library + breathing exercise
- AI-assisted journaling/CBT support (Gemini with fallback behavior)
- Goals management (add/edit/complete/delete)
- Daily reminder settings with local notifications
- Profile dashboard with streaks, milestone unlocks, and charts
- Curated mental health resources screen

## Tech Stack

- Flutter + Dart
- Provider (state management)
- Firebase Auth + Cloud Firestore
- flutter_local_notifications
- fl_chart
- google_generative_ai

## Project Structure

- `lib/screens` UI screens and flows
- `lib/widgets` reusable UI components
- `lib/providers` app state and domain logic
- `lib/services` external integrations (AI, notifications, APIs)
- `lib/models` typed data models
- `lib/data` local static datasets

## Setup

1. Install Flutter SDK and Firebase CLI.
2. Run dependency install:
   - `flutter pub get`
3. Configure Firebase for your platforms and ensure `lib/firebase_options.dart` is valid.
4. (Optional) Provide Gemini compile-time key:
   - `--dart-define=GEMINI_API_KEY=your_key`
5. Run app:
   - `flutter run`

## Testing

- Run widget tests:
  - `flutter test`
- See testing notes:
  - `docs/testing.md`

## Build APK

- Build Android release:
  - `flutter build apk --release`
- Output:
  - `build/app/outputs/flutter-apk/app-release.apk`

## Documentation

- Project report: `docs/report.md`
- Testing evidence/checklist: `docs/testing.md`
