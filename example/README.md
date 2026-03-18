# Hatch Example

## Running the example

```bash
cd example
flutter pub get
flutter run -t lib/main_dev.dart
```

## What to try

1. Two-finger long press to open Hatch
2. Switch environments — watch the URL update on the home screen
3. Tap "Fire test request" — watch it appear in the Network tab
4. Switch personas — watch the Profile screen update live
5. Toggle feature flags — watch the home screen change instantly
6. Open Shortcuts — jump to any screen in one tap
7. Open Settings → "Open Hatch" — programmatic trigger

## Running production mode (no Hatch)

```bash
flutter run -t lib/main.dart
```

Hatch is completely absent. No panel. No overlay. No imports.
