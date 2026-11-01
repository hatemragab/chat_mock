# Whizpee prototype app

Flutter client for the customer demonstration. Android and web are the configured targets. Sign-in, messaging, calls, media, permissions, payments and withdrawals are local simulations. Session state resets on restart or **Profile → Prototype tools → Reset demo**.

From this directory:

```sh
flutter pub get
flutter run -d chrome --no-web-resources-cdn
```

The seeded app opens on Discover. Use the five tabs for customer flows and Prototype tools to review named pages, overlays, scenarios, mock outcomes and the clock.

```sh
dart format lib test
flutter analyze
flutter test
flutter build web --no-web-resources-cdn
flutter build apk --debug
```

Build output is in `build/web/` and `build/app/outputs/flutter-apk/app-debug.apk`. The web flag bundles the renderer and default font; serve that directory through a local static server for an offline demo. See the [repository README](../README.md), [contributor guide](../AGENTS.md) and [acceptance audit](../docs/acceptance_audit.md) for scope, validation and device-testing limits.
