# Whizpee prototype

This repository contains an in-progress Flutter demonstration of the Whizpee client. The app uses local fixtures and session-only state; it does not connect to a backend or database. Work and remaining coverage are tracked in [the surface checklist](docs/ui_surface_checklist.md), [scenario checklist](docs/prototype_scenarios.md), and [acceptance audit](docs/acceptance_audit.md).

## Run locally

Install a compatible Flutter SDK (the project currently targets Dart 3.13.7 or later within the declared constraint), then from the repository root:

```sh
cd app
flutter pub get
flutter run -d chrome --no-web-resources-cdn
```

Android is also configured; choose an explicitly authorized Android target when running it. Device and UI testing is restricted by `AGENTS.md` to the specified iPhone simulator, but the project currently has no iOS platform target. Widget and controller tests do not require a device:

```sh
dart format lib test
flutter analyze
flutter test
flutter build web --no-web-resources-cdn
flutter build apk --debug
```

The app starts in a seeded session on Discover. Profile → Prototype tools contains review controls; Reset demo restores in-memory fixtures. Data is not saved across app restarts. The web build flag bundles the renderer and default font instead of loading them from a CDN. Serve `app/build/web/` through a local static server for a customer demo; opening `index.html` directly is not supported. The HTML file in the repository is the design reference, not a runtime dependency.
