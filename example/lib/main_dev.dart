import 'package:flutter/material.dart';
import 'package:hatch/hatch.dart';
import 'initialiser.dart';
import 'app.dart';
import 'screens/onboarding_screen.dart';
import 'screens/paywall_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/settings_screen.dart';

void main() async {
  await initialise();

  await Hatch.initFromAsset(
    'assets/hatch/hatch_config.json',
    options: const HatchOptions(
      triggerModes: {HatchTrigger.twoFingerLongPress, HatchTrigger.tripleClick},
      presentationStyle: HatchStyle.fullScreen,
      panelTheme: HatchTheme.system,
      dartDefineKeys: ['APP_ENV', 'API_VERSION'],
    ),
    defines: const {
      'LOCAL_BASE_URL': String.fromEnvironment('LOCAL_BASE_URL'),
      'STAGING_BASE_URL': String.fromEnvironment('STAGING_BASE_URL'),
      'PROD_BASE_URL': String.fromEnvironment('PROD_BASE_URL'),
      'ADMIN_EMAIL': String.fromEnvironment('ADMIN_EMAIL'),
      'ADMIN_PASSWORD': String.fromEnvironment('ADMIN_PASSWORD'),
      'ADMIN_RO_EMAIL': String.fromEnvironment('ADMIN_RO_EMAIL'),
      'ADMIN_RO_PASSWORD': String.fromEnvironment('ADMIN_RO_PASSWORD'),
      'PREMIUM_AU_EMAIL': String.fromEnvironment('PREMIUM_AU_EMAIL'),
      'PREMIUM_AU_PASSWORD': String.fromEnvironment('PREMIUM_AU_PASSWORD'),
      'PREMIUM_US_EMAIL': String.fromEnvironment('PREMIUM_US_EMAIL'),
      'PREMIUM_US_PASSWORD': String.fromEnvironment('PREMIUM_US_PASSWORD'),
      'TRIAL_EMAIL': String.fromEnvironment('TRIAL_EMAIL'),
      'TRIAL_PASSWORD': String.fromEnvironment('TRIAL_PASSWORD'),
      'FREE_AU_EMAIL': String.fromEnvironment('FREE_AU_EMAIL'),
      'FREE_AU_PASSWORD': String.fromEnvironment('FREE_AU_PASSWORD'),
      'FREE_US_EMAIL': String.fromEnvironment('FREE_US_EMAIL'),
      'FREE_US_PASSWORD': String.fromEnvironment('FREE_US_PASSWORD'),
      'UPGRADING_EMAIL': String.fromEnvironment('UPGRADING_EMAIL'),
      'UPGRADING_PASSWORD': String.fromEnvironment('UPGRADING_PASSWORD'),
    },
    onPersonaChanged: (persona) async {
      // In a real app this would call your AuthService.
      // In the example we just print to demonstrate the callback fires.
      debugPrint(
        '[Hatch] Persona changed → '
        '${persona?.name ?? "Guest"} '
        '(${persona?.role ?? "no role"})',
      );
    },
  );

  // Screen shortcuts — registered in Dart, not JSON
  // Shortcuts use MyApp.navigatorKey because onTap context is inside
  // the Hatch overlay, which is a sibling (not a descendant) of the
  // MaterialApp navigator.
  Hatch.addShortcut(
    label: 'Onboarding',
    group: 'Flows',
    description: 'Start the onboarding flow from scratch',
    onTap: (_) => MyApp.navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (_) => const OnboardingScreen(),
      ),
    ),
  );

  Hatch.addShortcut(
    label: 'Paywall',
    group: 'Subscription',
    description: 'Jump directly to the upgrade screen',
    onTap: (_) => MyApp.navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (_) => const PaywallScreen(),
      ),
    ),
  );

  Hatch.addShortcut(
    label: 'Settings',
    group: 'Navigation',
    onTap: (_) => MyApp.navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (_) => const SettingsScreen(),
      ),
    ),
  );

  Hatch.addShortcut(
    label: 'Profile',
    group: 'Navigation',
    onTap: (_) => MyApp.navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (_) => const ProfileScreen(),
      ),
    ),
  );

  runApp(const HatchApp(child: MyApp()));
}
