# Hatch

An in-app developer overlay for Flutter. Switch environments, personas, and feature flags - at runtime, without rebuilding.

---

## Screenshots

<img src="https://github.com/kapilmhr/hatch/raw/main/screenshots/environments.png" width="220" alt="Environments tab" /> <img src="https://github.com/kapilmhr/hatch/raw/main/screenshots/personas.png" width="220" alt="Personas tab" /> <img src="https://github.com/kapilmhr/hatch/raw/main/screenshots/flags.png" width="220" alt="Feature flags tab" /> <img src="https://github.com/kapilmhr/hatch/raw/main/screenshots/shortcuts.png" width="220" alt="Shortcuts tab" />

---

## The Problem

Without Hatch, switching from a staging API to a local API means:

1. Open your IDE
2. Change the base URL constant in code
3. Stop the running app
4. Rebuild and relaunch
5. Navigate back to the screen you were testing

**With Hatch**, you open the overlay panel (two-finger long press), tap "Local", and the URL changes instantly. No rebuild. No lost navigation state. Same for switching users, toggling feature flags, or jumping to any screen.

---

## Features

| Feature | Description |
|---|---|
| **Environment switching** | Switch API base URL at runtime - local, staging, production |
| **Persona switching** | Switch test user accounts with one tap, triggering your auth flow |
| **Feature flags** | Toggle flags on and off, see changes instantly via `HatchBuilder` |
| **Screen shortcuts** | Jump to any registered screen directly from the panel |
| **Dart defines** | Inspect `--dart-define` values without digging through build configs |
| **Production safe** | Zero Hatch code compiled into production builds (with recommended pattern) |

---

## How Entry Points Work

Flutter runs `lib/main.dart` by default. When you pass `-t lib/main_dev.dart` to `flutter run`, Flutter compiles only code reachable from that file.

Hatch uses this: your production `main.dart` never imports Hatch. Your dev `main_dev.dart` does. Therefore Hatch - including all test credentials - is never compiled into a production binary.
This is the recommended pattern.

There is also a simpler `kDebugMode` pattern (see [Production Safety](#production-safety) below) with honest tradeoffs.

---

## Installation

Add Hatch to your `pubspec.yaml`:

```yaml
dependencies:
  hatch: ^1.0.0
```

Declare your config asset:

```yaml
flutter:
  assets:
    - assets/hatch/
```

---

## Quick Start

### 1. Create the config file

Keep two files:

- `assets/hatch/hatch_config.example.json` (safe template, committed)
- `assets/hatch/hatch_config.json` (real local config, gitignored)

Copy template:

```bash
cp assets/hatch/hatch_config.example.json assets/hatch/hatch_config.json
```

Use `$VAR` placeholders for sensitive values:

```json
{
  "environments": [
    {
      "name": "Local",
      "baseUrl": "$LOCAL_BASE_URL",
      "personas": [
        {
          "name": "Admin User",
          "role": "admin",
          "tag": "full access",
          "credentials": { "email": "$ADMIN_EMAIL", "password": "$ADMIN_PASSWORD" }
        }
      ]
    }
  ]
}
```

Add this to your app `.gitignore`:

```gitignore
assets/hatch/hatch_config.json
```

### 2. Create initialiser.dart (shared)

```dart
// lib/initialiser.dart
import 'package:flutter/widgets.dart';

Future<void> initialise() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Firebase, notifications, deep links etc.
}
```

### 3. Create main_dev.dart (dev entry point)

```dart
// lib/main_dev.dart
import 'package:flutter/material.dart';
import 'package:hatch/hatch.dart';
import 'initialiser.dart';
import 'app.dart';

void main() async {
  await initialise();

  await Hatch.initFromAsset(
    'assets/hatch/hatch_config.json',
    defines: const {
      'LOCAL_BASE_URL': String.fromEnvironment('LOCAL_BASE_URL'),
      'STAGING_BASE_URL': String.fromEnvironment('STAGING_BASE_URL'),
      'PROD_BASE_URL': String.fromEnvironment('PROD_BASE_URL'),
      'ADMIN_EMAIL': String.fromEnvironment('ADMIN_EMAIL'),
      'ADMIN_PASSWORD': String.fromEnvironment('ADMIN_PASSWORD'),
    },
    onPersonaChanged: (persona) async {
      if (persona == null) return;
      await AuthService.loginWithCredentials(
        email: persona.credentials!.email,
        password: persona.credentials!.password,
      );
    },
  );

  Hatch.addShortcut(
    label: 'Paywall',
    group: 'Subscription',
    onTap: (ctx) => Navigator.of(ctx).pushNamed('/paywall'),
  );

  runApp(HatchApp(child: const MyApp()));
}
```

### 4. Create main.dart (production)

```dart
// lib/main.dart - PRODUCTION - zero Hatch imports
import 'package:flutter/widgets.dart';
import 'initialiser.dart';
import 'app.dart';

void main() async {
  await initialise();
  runApp(const MyApp());
}
```

### 5. Run commands

```bash
flutter run -t lib/main_dev.dart            # dev
flutter build apk -t lib/main.dart --release  # production
```

---

## Reading State

### Static Getters

```dart
Hatch.baseUrl;              // "https://staging.api.com"
Hatch.currentEnvironment;   // HatchEnvironment instance
Hatch.currentPersona;       // HatchPersona? (null if none selected)
Hatch.role;                 // "admin" or null
Hatch.flag('newDashboard'); // true or false (false for unknown keys)
```

### HatchBuilder (reactive)

```dart
HatchBuilder(
  builder: (context, state) {
    return Text('Current env: ${state.environment.name}');
  },
)
```

Rebuilds automatically whenever the environment, persona, or any flag changes.

### Feature Flag Pattern

```dart
HatchBuilder(
  builder: (context, state) {
    if (state.flag('newDashboard')) {
      return const NewDashboard();
    }
    return const LegacyDashboard();
  },
)
```

---

## Screen Shortcuts

Register shortcuts in your dev entry point:

### Navigator

```dart
Hatch.addShortcut(
  label: 'Paywall',
  group: 'Subscription',
  onTap: (ctx) => Navigator.of(ctx).push(
    MaterialPageRoute(builder: (_) => const PaywallScreen()),
  ),
);
```

### GoRouter

```dart
Hatch.addShortcut(
  label: 'Settings',
  group: 'Navigation',
  onTap: (ctx) => GoRouter.of(ctx).go('/settings'),
);
```

### auto_route

```dart
Hatch.addShortcut(
  label: 'Profile',
  group: 'Navigation',
  onTap: (ctx) => AutoRouter.of(ctx).push(const ProfileRoute()),
);
```

---

## Configuration Reference

### Environment

| Field | Type | Required | Default | Description |
|---|---|---|---|---|
| `name` | `String` | Yes | - | Unique display name |
| `baseUrl` | `String` | Yes | - | Full URL including scheme |
| `headers` | `Map<String, String>` | No | `{}` | Merged into every request (`$VAR` supported) |
| `isDangerous` | `bool` | No | `false` | Shows confirmation dialog |
| `personas` | `List<Persona>` | No | `[]` | Personas available in this environment |

### Persona

| Field | Type | Required | Default | Description |
|---|---|---|---|---|
| `name` | `String` | Yes | - | Unique display name (within environment) |
| `role` | `String?` | No | `null` | e.g. "admin", "user" |
| `tag` | `String?` | No | `null` | e.g. "AU region", "trial" |
| `credentials` | `Object?` | No | `null` | Email, password, apiToken, extra (`$VAR` supported) |

### Feature Flag

| Field | Type | Required | Default | Description |
|---|---|---|---|---|
| `name` | `String` | Yes | - | Unique flag identifier |
| `enabled` | `bool` | No | `false` | Initial state |
| `description` | `String?` | No | `null` | Shown in panel |

---

## Full initFromAsset Example

```dart
await Hatch.initFromAsset(
  'assets/hatch/hatch_config.json',
  options: const HatchOptions(
    triggerModes: {HatchTrigger.twoFingerLongPress, HatchTrigger.tripleClick},
    presentationStyle: HatchStyle.fullScreen,
    panelTheme: HatchTheme.system,
    dartDefineKeys: ['APP_ENV', 'API_VERSION'],
  ),
  defines: const {
    'STAGING_BASE_URL': String.fromEnvironment('STAGING_BASE_URL'),
    'ADMIN_EMAIL': String.fromEnvironment('ADMIN_EMAIL'),
    'ADMIN_PASSWORD': String.fromEnvironment('ADMIN_PASSWORD'),
  },
  onPersonaChanged: (persona) async {
    if (persona == null) return;
      email: persona.credentials!.email,
      password: persona.credentials!.password,
    );
  },
);
```

---

## VS Code launch.json

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Dev (Hatch)",
      "request": "launch",
      "type": "dart",
      "program": "lib/main_dev.dart"
    },
    {
      "name": "Production",
      "request": "launch",
      "type": "dart",
      "program": "lib/main.dart"
    }
  ]
}
```

---

## CI/CD Example

```yaml
# .github/workflows/build.yml
name: Build

on:
  push:
    branches: [main]

jobs:
  build-dev:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter test
      - run: flutter build apk -t lib/main_dev.dart

  build-staging:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter build apk -t lib/main.dart --dart-define=APP_ENV=staging

  build-production:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter build apk -t lib/main.dart --release
```

---

## Production Safety

### Pattern A - Separate Entry Points (Recommended)

Your production `main.dart` never imports `package:hatch`. The Dart compiler only compiles code reachable from the specified entry point. Hatch, all test personas, and all credentials are structurally excluded from the production binary.

```bash
flutter build apk -t lib/main.dart --release  # zero Hatch code
```

### Pattern B - kDebugMode (Simple)

```dart
import 'package:hatch/hatch.dart'; // still compiled

void main() async {
  if (kDebugMode) {
    await Hatch.initFromAsset('assets/hatch/hatch_config.json');
    runApp(HatchApp(child: const MyApp()));
  } else {
    runApp(const MyApp());
  }
}
```

**Tradeoff:** The `import` at the top of the file means Hatch code (including credentials in the JSON asset) is compiled into the binary even in release mode. The `if` block prevents execution but not compilation. Acceptable for most apps. Not recommended for security-sensitive apps.

---

## API Reference

### Hatch

```dart
static Future<void> initFromAsset(String assetPath, {HatchOptions? options, Map<String, String> defines = const {}, Future<void> Function(HatchPersona?)? onPersonaChanged})
static void addShortcut({required String label, required void Function(BuildContext) onTap, String? group, String? description, IconData? icon})
static String get baseUrl
static HatchEnvironment get currentEnvironment
static HatchPersona? get currentPersona
static String? get role
static Stream<HatchState> get stream
static bool flag(String name)
static void open()
static void close()
```

### HatchOptions

```dart
const HatchOptions({
  Set<HatchTrigger> triggerModes = const {HatchTrigger.twoFingerLongPress},
  HatchStyle presentationStyle = HatchStyle.fullScreen,
  HatchTheme panelTheme = HatchTheme.system,
  List<String> dartDefineKeys = const [],
})
```

## Placeholder Resolution and CI

When a config string starts with `$`, Hatch resolves it from `defines`.

- Local: pass values from `--dart-define`
- VS Code: set `args` in `launch.json`
- Android Studio: use Additional run args
- CI/CD: pass secrets as `--dart-define=KEY=...`

Example CI:

```yaml
- run: flutter build apk -t lib/main_dev.dart \
    --dart-define=STAGING_BASE_URL=${{ secrets.STAGING_BASE_URL }} \
    --dart-define=ADMIN_EMAIL=${{ secrets.ADMIN_EMAIL }} \
    --dart-define=ADMIN_PASSWORD=${{ secrets.ADMIN_PASSWORD }}
```

### HatchState

```dart
final HatchEnvironment environment;
final HatchPersona? persona; // null if none selected
final List<HatchFlag> flags;
bool flag(String name);
```

---

## FAQ

### Does it work on physical devices?

Yes. The two-finger long press trigger works on both simulators and physical devices. The shake trigger requires a physical device.

### Is it compatible with GoRouter / auto_route?

Yes. Shortcuts accept a `void Function(BuildContext)` callback. Use `GoRouter.of(ctx).go(...)` or `AutoRouter.of(ctx).push(...)` in the callback.

### Are credentials stored to disk?

Never. Only the environment name and persona name strings are persisted via SharedPreferences. Credentials exist only in memory, loaded from the JSON asset at startup.

### Is Hatch compiled into my production binary?

With Pattern A (separate entry points): **No.** The Dart compiler only includes code reachable from the specified entry point. If `main.dart` never imports Hatch, it's excluded.

With Pattern B (kDebugMode): **Yes**, but never executed. The import causes compilation regardless of the if-block.

### Can I open the panel programmatically?

Yes. Call `Hatch.open()` from anywhere - for example, a "Dev Tools" button in your settings screen.

### What happens if I call flag() with an unknown name?

Returns `false`. Never throws. Never returns null.

---

## Contributing

Contributions welcome. Please open an issue before submitting a PR for significant changes.

```bash
git clone https://github.com/kapilmhr/hatch.git
cd hatch
flutter pub get
flutter test
flutter analyze
```

---

## License

MIT. See [LICENSE](LICENSE).
