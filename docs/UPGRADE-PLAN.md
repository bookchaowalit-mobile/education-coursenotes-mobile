# Upgrade Plan — Coursenotes Mobile

## Current state

Score: 7.5/10 — persisted notes with search/filter, undoable delete, unicode-correct limits, a11y guideline tests and fail-closed signing; no edit/export, icon or E2E flow yet.

## Backlog

### P0
- None open. (Release signing now fails closed without `android/key.properties`.)

### P1
- Export/import notes as JSON or Markdown (share sheet) so they survive a reinstall.
- Edit an existing note (currently add/delete only).
- Replace the template launcher icon with a real app icon (the application ID `com.bookchaowalit.*` is already set).
- Add a Maestro smoke flow for the main journey.
- Add a CI job that builds a signed release bundle from repository secrets (keystore decoded at runtime, never committed).

### P2
- Tablet layout (NavigationRail).
- Localisation (Thai/English) for UI strings.

## Done in this pass (pass 3)

- Bug fix: with topics "Graphs" and "graphs", deleting the note whose spelling was on the selected chip silently cleared the filter (exact-match check against case-insensitive topics). The filter now survives and follows the remaining spelling (`hasTopic`).
- Bug fix: the 5000-character note limit counted UTF-16 code units (emoji counted twice); it now counts visible characters (`characters`, now a direct dependency).
- Error state: deleting a note shows an "Undo" snack bar that restores it; the dialog's validation error is a live region; course/topic fields move focus with "next".
- Edge-case unit tests: emoji/whitespace limits, whitespace-only and tab/newline queries, Thai/emoji search, same-timestamp ordering, empty collections, JSON round trip with unicode.
- Widget tests: undo, filter-after-delete, cancel, a11y guidelines (tap target, labels, contrast), 200% text scale.

## Done in pass 2

- Release builds no longer sign with the debug key: `android/app/build.gradle.kts` reads the ignored `android/key.properties` and a Gradle guard fails any release assemble/bundle without it (pattern from `bookchaowalit-goal-tracker-mobile`). Root `.gitignore` also ignores `key.properties`, `*.jks`, `*.keystore`; README documents the setup. Not build-verified here (no Android SDK/Gradle in this environment).
- Notes now persist on device: `lib/data/list_repository.dart` (`ListRepository` interface, `shared_preferences` JSON implementation that skips malformed records, in-memory implementation for tests); the home screen loads on start, saves after add/delete and shows an error line when storage fails.
- Added repository tests (round trip, empty, malformed records, non-list payload) and widget tests for restore/save and load failure.

## Done in pass 1

- Replaced the Expo/npm CI (which could never fail) with fail-closed Flutter CI: `dart format` check, `flutter analyze`, `flutter test`, debug APK on `main`.
- Implemented the core feature (keep short study notes per course and find them again quickly) with pure-Dart logic in `lib/logic/`.
- Replaced placeholder Explore/Profile tabs with an About screen describing features and privacy.
- Added unit tests for the logic and widget tests for the main journey.
- Removed unused `go_router` / `flutter_riverpod` dependencies; README now matches the code.
