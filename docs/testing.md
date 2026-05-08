# Testing Notes

## Automated Tests (Widget)
Implemented in `test/widget_test.dart`:

1. `PrimaryButton` renders and triggers callback on tap.
2. `SectionHeader` displays title, subtitle, and trailing icon.
3. `ProgressRing` renders expected indicators and center content.

Run:

```bash
flutter test
```

## Manual Test Checklist

- Authentication:
  - Sign up/login succeeds
  - Logout returns to splash/login screen
- Mood flow:
  - Select mood and verify save feedback
  - Check dashboard counts update after mood/activity/journal actions
- Journaling:
  - Add entry and verify it appears in today's list
  - Delete entry and verify removal
- Goals/reminders:
  - Add/edit/complete/delete goal
  - Save reminder settings and verify success message
- Meditation/resources:
  - Open meditation library and start a session/timer
  - Open mental health resources links
- Error handling:
  - Simulate no network and verify user-facing error snackbar on network-dependent actions

## Known Gaps

- No full integration test suite yet (widget baseline implemented).
- Performance profiling evidence should be captured separately if required by evaluator.
