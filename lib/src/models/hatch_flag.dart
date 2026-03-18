/// Represents a feature flag that can be toggled at runtime.
///
/// The [enabled] field is mutable — it is toggled from the Hatch panel.
/// Flag state is not persisted; flags reset to JSON defaults on restart.
class HatchFlag {
  /// The unique name of the flag (e.g. "newDashboard").
  final String name;

  /// Whether this flag is currently enabled. Mutable at runtime.
  bool enabled;

  /// An optional description shown in the panel.
  final String? description;

  /// Creates a new [HatchFlag].
  HatchFlag({
    required this.name,
    required this.enabled,
    this.description,
  });
}
