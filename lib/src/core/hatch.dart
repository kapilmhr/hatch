import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/hatch_config_exception.dart';
import '../models/hatch_environment.dart';
import '../models/hatch_persona.dart';
import '../models/hatch_shortcut.dart';
import 'hatch_initialiser.dart';
import 'hatch_options.dart';
import 'hatch_registry.dart';
import 'hatch_state.dart';

/// The main entry point for the Hatch developer overlay.
///
/// Call [Hatch.initFromAsset] to initialise, then wrap your app
/// with [HatchApp] to enable the overlay panel.
class Hatch {
  Hatch._();

  static bool _initialised = false;

  /// Initialises Hatch from a JSON configuration file in the asset bundle.
  ///
  /// Must be called before [HatchApp] is rendered.
  ///
  /// ```dart
  /// await Hatch.initFromAsset('assets/hatch/hatch_config.json');
  /// ```
  static Future<void> initFromAsset(
    String assetPath, {
    HatchOptions? options,
    Map<String, String> defines = const {},
    Future<void> Function(HatchPersona?)? onPersonaChanged,
  }) async {
    if (_initialised) {
      debugPrint('[Hatch] Already initialised. Ignoring duplicate call.');
      return;
    }

    await HatchInitialiser.initFromAsset(
      assetPath,
      options: options,
      defines: defines,
      onPersonaChanged: onPersonaChanged,
    );

    _initialised = true;
  }

  /// Registers a screen shortcut in the Hatch panel.
  ///
  /// Must be called after [initFromAsset]. Order of calls determines
  /// display order. Shortcuts with the same [group] appear under a
  /// shared header.
  static void addShortcut({
    required String label,
    required void Function(BuildContext) onTap,
    String? group,
    String? description,
    IconData? icon,
  }) {
    if (!_initialised || HatchRegistry.instance == null) {
      throw const HatchStateException(
        'Call Hatch.initFromAsset() before adding shortcuts.',
      );
    }

    HatchRegistry.instance!.shortcuts.add(HatchShortcut(
      label: label,
      onTap: onTap,
      group: group,
      description: description,
      icon: icon,
    ));
  }

  /// The active environment's base URL.
  ///
  /// Always returns a non-null, non-empty string after [initFromAsset]
  /// completes. Returns an empty string if called before initialisation.
  ///
  /// Use this to configure your HTTP client:
  /// ```dart
  /// final dio = Dio(BaseOptions(baseUrl: Hatch.baseUrl));
  /// ```
  static String get baseUrl =>
      HatchRegistry.instance?.activeEnvironment.baseUrl ?? '';

  /// The currently active environment.
  static HatchEnvironment get currentEnvironment =>
      HatchRegistry.instance?.activeEnvironment ??
      const HatchEnvironment(name: '', baseUrl: '');

  /// The currently active persona, or `null` if guest.
  static HatchPersona? get currentPersona =>
      HatchRegistry.instance?.activePersona;

  /// The role of the currently active persona, or `null`.
  static String? get role =>
      HatchRegistry.instance?.activePersona?.role;

  /// A stream of [HatchState] emitted whenever the environment,
  /// persona, or a feature flag changes.
  static Stream<HatchState> get stream =>
      HatchRegistry.instance?.stream ?? const Stream.empty();

  /// Returns whether the flag with the given [name] is enabled.
  ///
  /// Returns `false` for unknown flag names. Never null. Never throws.
  static bool flag(String name) {
    final registry = HatchRegistry.instance;
    if (registry == null) return false;
    for (final f in registry.flags) {
      if (f.name == name) return f.enabled;
    }
    return false;
  }

  /// Switches the active environment.
  static Future<void> setEnvironment(HatchEnvironment environment) async {
    final registry = HatchRegistry.instance;
    if (registry == null) return;

    registry.activeEnvironment = environment;

    // Reset the active persona if it does not exist in the new environment
    final currentPersona = registry.activePersona;
    if (currentPersona != null &&
        !environment.personas.any((p) => p.name == currentPersona.name)) {
      registry.activePersona = null;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('hatch_active_env', environment.name);

    registry.emit();
  }

  /// Switches the active persona.
  static Future<void> setPersona(HatchPersona? persona) async {
    final registry = HatchRegistry.instance;
    if (registry == null) return;

    registry.activePersona = persona;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('hatch_active_persona', persona?.name ?? '');

    registry.emit();

    if (registry.onPersonaChanged != null) {
      try {
        await registry.onPersonaChanged!(persona);
      } catch (e) {
        debugPrint('[Hatch] onPersonaChanged callback threw: $e');
      }
    }
  }

  /// Toggles a feature flag by name.
  static void toggleFlag(String name) {
    final registry = HatchRegistry.instance;
    if (registry == null) return;

    for (final f in registry.flags) {
      if (f.name == name) {
        f.enabled = !f.enabled;
        registry.emit();
        return;
      }
    }
  }

  /// Programmatically opens the Hatch panel.
  ///
  /// Useful for adding a "Dev Tools" button in your app's settings.
  static void open() {
    HatchRegistry.instance?.openPanel?.call();
  }

  /// Programmatically closes the Hatch panel.
  static void close() {
    HatchRegistry.instance?.closePanel?.call();
  }

  /// Whether Hatch has been initialised.
  static bool get isInitialised => _initialised;

  /// Resets Hatch state. For testing only.
  @visibleForTesting
  static void reset() {
    _initialised = false;
    HatchRegistry.reset();
  }
}
