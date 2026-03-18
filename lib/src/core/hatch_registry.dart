import 'dart:async';

import '../models/hatch_environment.dart';
import '../models/hatch_flag.dart';
import '../models/hatch_persona.dart';
import '../models/hatch_shortcut.dart';
import 'hatch_options.dart';
import 'hatch_state.dart';

/// Internal singleton that holds all Hatch state.
///
/// Not exported. All public [Hatch.*] getters read from this.
class HatchRegistry {
  HatchRegistry._();

  static HatchRegistry? _instance;

  /// Returns the singleton instance, or `null` if not initialised.
  static HatchRegistry? get instance => _instance;

  /// Creates and returns the singleton instance.
  static HatchRegistry create() {
    _instance = HatchRegistry._();
    return _instance!;
  }

  /// Resets the singleton (for testing).
  static void reset() {
    _instance?._controller.close();
    _instance = null;
  }

  // Config
  List<HatchEnvironment> environments = [];
  List<HatchFlag> flags = [];
  List<HatchShortcut> shortcuts = [];
  HatchOptions options = const HatchOptions();
  Map<String, String> dartDefines = {};

  // Runtime state
  late HatchEnvironment activeEnvironment;
  HatchPersona? activePersona;

  // Reactive
  final StreamController<HatchState> _controller =
      StreamController<HatchState>.broadcast();

  /// Stream of state changes.
  Stream<HatchState> get stream => _controller.stream;

  // Callbacks
  Future<void> Function(HatchPersona?)? onPersonaChanged;

  // Panel state
  bool isPanelOpen = false;
  void Function()? openPanel;
  void Function()? closePanel;

  /// Emits the current state on the stream.
  void emit() {
    _controller.add(HatchState(
      environment: activeEnvironment,
      persona: activePersona,
      flags: flags,
    ));
  }

  /// Returns the current state snapshot.
  HatchState get currentState => HatchState(
        environment: activeEnvironment,
        persona: activePersona,
        flags: flags,
      );
}
