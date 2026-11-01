# Repository Guidelines

## Project Structure & Goal

The source for the customer-facing mock is [Whizpee_Responsive_UI_Handoff](Whizpee_Responsive_UI_Handoff/). Follow its screen specifications, design tokens, component contracts, and visual references. Reproduce its pages, widgets, navigation, and interactions in Flutter with local mock data and state; do not add a backend or database. Keep the prototype usable without external services.

The Flutter project is in `app/`. Application code starts in `app/lib/main.dart`, and widget tests live in `app/test/`. Platform configuration is in `app/android/` and `app/web/`; these are the supported targets. Bundled Story artwork lives in `app/assets/story/` and is declared in `app/pubspec.yaml`; declare additional assets there when needed.

## Build, Test & Development

Run commands from `app/`:

- `flutter pub get` — install the declared dependencies.
- `flutter run -d chrome --no-web-resources-cdn` — run the web prototype locally.
- `dart format lib test` — format Dart source and tests.
- `flutter analyze` — run static analysis and the configured lints.
- `flutter test` — run unit and widget tests.
- `flutter build web --no-web-resources-cdn` and `flutter build apk --debug` — verify self-contained web and Android builds.

For requested device or UI tests, use only the existing iPhone 17 Pro, iOS 26.0 simulator with UDID `3CC14436-EC3C-4419-A079-C84951E5FA07`. This project currently has no iOS target; report that limitation instead of selecting another device or adding a platform without instruction.

## Coding Style & Testing

Use idiomatic, null-safe Dart with two-space indentation. Follow existing style and `app/analysis_options.yaml` (`flutter_lints`). Name Dart files in `snake_case`, types in `UpperCamelCase`, and members in `lowerCamelCase`.

Organize `app/lib/` by feature, keeping each feature's screens, widgets, state, and mock data together. Put reusable widgets shared across features in `app/lib/shared/widgets/` and reuse them instead of duplicating UI. Keep English interface strings in feature `copy/` catalogs; common actions belong in `app/lib/shared/copy/`. Keep technical IDs and fixture content separate from presentation copy. Define one widget per Dart file; keep state and navigation understandable.

Add meaningful `flutter_test` tests for changed behavior. Name test files `*_test.dart`, describe the user-visible behavior, and cover navigation and interaction edge cases where practical. Run formatting, analysis, relevant tests, and builds before finishing.

## Commits, Reviews & Configuration

Use concise, imperative commit subjects. Pull requests should describe the change, link an issue when applicable, list validation, and include screenshots for visual changes.

Do not commit credentials, local configuration, generated build output, `.dart_tool/`, or IDE files. Do not commit, push, publish, or deploy without explicit authorization.
