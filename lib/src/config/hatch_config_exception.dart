/// Exception thrown when the Hatch configuration is invalid.
class HatchConfigException implements Exception {
  /// The error message.
  final String message;

  /// Creates a [HatchConfigException] with the given [message].
  const HatchConfigException(this.message);

  @override
  String toString() => 'HatchConfigException: $message';
}

/// Exception thrown when Hatch methods are called in an invalid state.
class HatchStateException implements Exception {
  /// The error message.
  final String message;

  /// Creates a [HatchStateException] with the given [message].
  const HatchStateException(this.message);

  @override
  String toString() => 'HatchStateException: $message';
}
