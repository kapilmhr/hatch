import 'hatch_persona.dart';

/// Represents an API environment that the app can target.
///
/// Each environment has a [name], [baseUrl], optional [headers],
/// an [isDangerous] flag that triggers a confirmation dialog
/// when switching to it, and its own [personas] list.
class HatchEnvironment {
  /// The display name of the environment (e.g. "Staging", "Production").
  final String name;

  /// The full base URL including scheme (e.g. "https://api.example.com").
  final String baseUrl;

  /// Optional headers merged into every request when this environment is active.
  final Map<String, String> headers;

  /// Whether this environment points to production data.
  ///
  /// When `true`, switching to this environment shows a confirmation dialog.
  final bool isDangerous;

  /// The personas available when this environment is active.
  final List<HatchPersona> personas;

  /// Creates a new [HatchEnvironment].
  const HatchEnvironment({
    required this.name,
    required this.baseUrl,
    this.headers = const {},
    this.isDangerous = false,
    this.personas = const [],
  });
}
