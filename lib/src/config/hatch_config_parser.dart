import '../models/hatch_credentials.dart';
import '../models/hatch_environment.dart';
import '../models/hatch_flag.dart';
import '../models/hatch_persona.dart';
import 'hatch_config_exception.dart';

/// Parsed configuration from hatch_config.json.
class HatchConfig {
  final List<HatchEnvironment> environments;
  final List<HatchFlag> flags;

  const HatchConfig({
    required this.environments,
    required this.flags,
  });
}

/// Parses and validates a Hatch JSON configuration.
class HatchConfigParser {
  const HatchConfigParser._();

  /// Parses a decoded JSON map into a [HatchConfig].
  ///
  /// If [defines] is provided, any string value starting with `$`
  /// (for example, `$STAGING_BASE_URL`) is resolved from the map.
  /// Unresolved variables are left as-is.
  ///
  /// Throws [HatchConfigException] if the configuration is invalid.
  static HatchConfig parse(
    Map<String, dynamic> json, {
    Map<String, String> defines = const {},
  }) {
    // Parse environments (personas are nested inside each environment)
    final environments = _parseEnvironments(json, defines);

    // Parse feature flags
    final flags = _parseFlags(json);

    return HatchConfig(
      environments: environments,
      flags: flags,
    );
  }

  static String _resolve(String value, Map<String, String> defines) {
    if (!value.startsWith(r'$') || value.length < 2) return value;
    final key = value.substring(1);
    return defines[key] ?? value;
  }

  static List<HatchEnvironment> _parseEnvironments(
      Map<String, dynamic> json, Map<String, String> defines) {
    final envList = json['environments'];
    if (envList == null || envList is! List) {
      throw const HatchConfigException(
        'environments must be a non-empty array.',
      );
    }
    if (envList.isEmpty) {
      throw const HatchConfigException(
        'environments must be a non-empty array.',
      );
    }

    final names = <String>{};
    final environments = <HatchEnvironment>[];

    for (var i = 0; i < envList.length; i++) {
      final env = envList[i];
      if (env is! Map<String, dynamic>) {
        throw HatchConfigException(
          'Environment at index $i is not a valid object.',
        );
      }

      final name = env['name'];
      if (name == null || name is! String || name.isEmpty) {
        throw HatchConfigException(
          'Environment at index $i is missing required field "name".',
        );
      }

      final baseUrl = env['baseUrl'];
      if (baseUrl == null || baseUrl is! String || baseUrl.isEmpty) {
        throw HatchConfigException(
          'Environment at index $i is missing required field "baseUrl".',
        );
      }
      final resolvedBaseUrl = _resolve(baseUrl, defines);

      if (names.contains(name)) {
        throw HatchConfigException('Duplicate environment name "$name".');
      }
      names.add(name);

      final headersRaw = env['headers'];
      final headers = <String, String>{};
      if (headersRaw is Map) {
        for (final entry in headersRaw.entries) {
          headers[entry.key.toString()] =
              _resolve(entry.value.toString(), defines);
        }
      }

      final isDangerous = env['isDangerous'] as bool? ?? false;

      // Parse personas nested inside this environment
      final personas = _parsePersonasFromList(
        env['personas'],
        envName: name,
        defines: defines,
      );

      environments.add(HatchEnvironment(
        name: name,
        baseUrl: resolvedBaseUrl,
        headers: headers,
        isDangerous: isDangerous,
        personas: personas,
      ));
    }

    return environments;
  }

  static List<HatchPersona> _parsePersonasFromList(
    dynamic personaList, {
    required String envName,
    Map<String, String> defines = const {},
  }) {
    if (personaList == null || personaList is! List) {
      return [];
    }

    final names = <String>{};
    final personas = <HatchPersona>[];

    for (var i = 0; i < personaList.length; i++) {
      final p = personaList[i];
      if (p is! Map<String, dynamic>) continue;

      final name = p['name'];
      if (name == null || name is! String || name.isEmpty) {
        throw HatchConfigException(
          'Persona at index $i in environment "$envName" is missing required field "name".',
        );
      }

      if (names.contains(name)) {
        throw HatchConfigException(
            'Duplicate persona name "$name" in environment "$envName".');
      }
      names.add(name);

      final role = p['role'] as String?;
      final tag = p['tag'] as String?;

      HatchCredentials? credentials;
      final creds = p['credentials'];
      if (creds is Map<String, dynamic>) {
        final email = creds['email'] as String?;
        final password = creds['password'] as String?;
        if (email != null && password != null) {
          final apiToken = creds['apiToken'] as String?;
          final extraRaw = creds['extra'];
          final extra = <String, String>{};
          if (extraRaw is Map) {
            for (final entry in extraRaw.entries) {
              extra[entry.key.toString()] =
                  _resolve(entry.value.toString(), defines);
            }
          }
          credentials = HatchCredentials(
            email: _resolve(email, defines),
            password: _resolve(password, defines),
            apiToken: apiToken != null ? _resolve(apiToken, defines) : null,
            extra: extra,
          );
        }
      }

      personas.add(HatchPersona(
        name: name,
        role: role,
        tag: tag,
        credentials: credentials,
      ));
    }

    return personas;
  }

  static List<HatchFlag> _parseFlags(Map<String, dynamic> json) {
    final flagList = json['featureFlags'];
    if (flagList == null || flagList is! List) {
      return [];
    }

    final flags = <HatchFlag>[];

    for (var i = 0; i < flagList.length; i++) {
      final f = flagList[i];
      if (f is! Map<String, dynamic>) continue;

      final name = f['name'] as String?;
      if (name == null || name.isEmpty) continue;

      final enabled = f['enabled'] as bool? ?? false;
      final description = f['description'] as String?;

      flags.add(HatchFlag(
        name: name,
        enabled: enabled,
        description: description,
      ));
    }

    return flags;
  }
}
