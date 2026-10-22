# Coursenotes (mobile) — product sheet

Describes only what exists in this repository today.

## What it is

A small Flutter (Material 3) app for keeping short study notes per course and
finding them again. It is also the **canonical Flutter template** for the
name-substituted Flutter copies in the `bookchaowalit-mobile` organisation
(see README).

## Who it is for

One person studying on one Android device. There is no account, sharing or sync.

## Screens

| Screen | What it does |
|---|---|
| Notes (home) | List of notes newest first; search box across course, topic and body; topic filter chips; "Add note" button; delete with an Undo snack bar |
| New note (dialog) | Course, topic and body fields with validation (body limit counts visible characters, so emoji count once) |
| About | Short description, feature list, privacy note, author link |

Navigation is a two-tab bottom `NavigationBar` (Notes, About).

## Data

- Stored only on the device with `shared_preferences` (JSON under a versioned key).
- No backend, no network calls, no analytics, no crash reporting.
- Uninstalling the app deletes the notes; there is no export yet.

## Quality evidence

- Unit tests: `test/notes_test.dart` (search, filter, limits, ordering),
  `test/note_repository_test.dart` (JSON round trip, persistence).
- Widget tests: `test/widget_test.dart` (add/delete/undo, filter after delete,
  accessibility guidelines, 200% text scale at phone width).
- CI (`.github/workflows/build.yml`): Flutter pinned in workflow env,
  `pub get --enforce-lockfile`, format, analyze and test all fail closed;
  shared `security.yml` scan; a debug APK artifact on `main` pushes.

## Not in scope / not done

- No store listing (Google Play / App Store) and no signed release build:
  release builds fail on purpose until an upload keystore is configured.
- No iOS project in the repo; Android only.
- No edit or export of notes yet (see `docs/UPGRADE-PLAN.md`).
