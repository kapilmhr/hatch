import 'hatch_credentials.dart';

/// Represents a test user persona with optional credentials.
///
/// Personas allow developers to quickly switch between different
/// user accounts and roles while testing.
class HatchPersona {
  /// The display name of the persona (e.g. "Admin User", "Free User").
  final String name;

  /// The role of this persona (e.g. "admin", "user"), or `null`.
  final String? role;

  /// A short label that explains why this persona exists, shown as a badge
  /// (e.g. "AU region", "trial", "upgrading"). Optional.
  final String? tag;

  /// The test credentials for this persona, or `null` for guest.
  final HatchCredentials? credentials;

  /// Creates a new [HatchPersona].
  const HatchPersona({
    required this.name,
    this.role,
    this.tag,
    this.credentials,
  });
}
