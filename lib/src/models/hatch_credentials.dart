/// Represents a set of credentials for a test persona.
///
/// Credentials are never serialised to SharedPreferences or any
/// persistent storage. Only the persona name is persisted.
class HatchCredentials {
  /// The email address for this test account.
  final String email;

  /// The password for this test account.
  final String password;

  /// An optional API token.
  final String? apiToken;

  /// Additional key-value pairs for custom credential fields.
  final Map<String, String> extra;

  /// Creates a new [HatchCredentials].
  const HatchCredentials({
    required this.email,
    required this.password,
    this.apiToken,
    this.extra = const {},
  });
}
