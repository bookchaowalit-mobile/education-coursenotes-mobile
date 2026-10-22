# Coursenotes — Mobile

Keep short study notes per course and find them again quickly.

Part of [Chaowalit Greepoke](https://bookchaowalit.com)'s 101 Portfolio Projects.

## Canonical Flutter template

This repo **is the canonical Flutter (Material 3) template** in
`bookchaowalit-mobile`. The following repos are name-substituted copies of
this scaffold; fixes land here first and are then copied per repo (each repo
owns its code, no shared package):

- community-guestbook-mobile, games-game-collection-mobile,
  marketing-contact-forms-mobile, productivity-ideas-mobile,
  commerce-digital-products-mobile, community-donation-tip-jar-mobile,
  devtools-design-mobile, devtools-devhub-mobile, devtools-error-logs-mobile,
  marketing-deeplinks-mobile, marketing-giveaways-mobile
- devtools-github-mobile (bare scaffold of the same shape, no app logic yet)

Consolidation or archiving of the copies is pending owner decision D5
(BD-033), see `repository-catalog/portfolio/MOBILE-CONSOLIDATION-2026-10.md`
in solo-empire. Product scope: [PRODUCT.md](PRODUCT.md).

## Features

- Add notes with course, topic and body
- Search across course, topic and body text
- Filter by topic chips; delete notes

Data is saved on this device with `shared_preferences` (JSON under a
versioned key); there is no account, backend, analytics or network access.

## Tech Stack

- **Framework:** Flutter (CI pinned to 3.47.5) + Material 3
- **Language:** Dart
- **State:** `StatefulWidget` / `setState`; the core logic is pure Dart in
  `lib/logic/` and unit-tested without widgets
- **Persistence:** `shared_preferences` behind a small `ListRepository`
  interface in `lib/data/` (in-memory implementation for tests)

## Develop and verify

```bash
flutter pub get
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
flutter run
```

CI (`.github/workflows/build.yml`) pins Flutter in the workflow `env`,
resolves dependencies with `flutter pub get --enforce-lockfile`, runs the same
format/analyze/test checks (all fail closed) plus the shared
`platform-ci-workflows` `security.yml` scan, and on pushes to `main` builds a
debug APK uploaded as a `NOT-FOR-STORE` artifact.

## Build

```bash
# Android
flutter build apk --debug
```

Release builds (`flutter build apk --release` / `appbundle`) fail on purpose
until signing is configured; they never fall back to the debug key. To sign,
create an upload keystore outside the repo and add the ignored
`android/key.properties`:

```properties
storePassword=...
keyPassword=...
keyAlias=upload
storeFile=/absolute/path/to/upload-keystore.jks
```

Never commit `key.properties` or keystores (both are git-ignored).

## Related

- **Frontend:** [bookchaowalit-website/coursenotes-frontend](https://github.com/bookchaowalit-website/coursenotes-frontend)
- **Portfolio:** [bookchaowalit.com](https://bookchaowalit.com)

## License

MIT
