import '../models/hatch_environment.dart';
import '../models/hatch_flag.dart';
import '../models/hatch_persona.dart';

/// Immutable snapshot of the current Hatch state.
///
/// Emitted on [Hatch.stream] whenever the environment, persona,
/// or a feature flag changes.
class HatchState {
  /// The currently active environment.
  final HatchEnvironment environment;

  /// The currently active persona, or `null` if guest.
  final HatchPersona? persona;

  /// The list of all feature flags with their current states.
  final List<HatchFlag> flags;

  /// Creates a new [HatchState].
  const HatchState({
    required this.environment,
    this.persona,
    required this.flags,
  });

  /// Returns whether the flag with the given [name] is enabled.
  ///
  /// Returns `false` for unknown flag names. Never null. Never throws.
  bool flag(String name) {
    for (final f in flags) {
      if (f.name == name) return f.enabled;
    }
    return false;
  }
}
