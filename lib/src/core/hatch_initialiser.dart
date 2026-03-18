import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/hatch_config_exception.dart';
import '../config/hatch_config_parser.dart';
import '../models/hatch_persona.dart';
import 'hatch_options.dart';
import 'hatch_registry.dart';

/// Handles the Hatch initialisation sequence.
class HatchInitialiser {
  const HatchInitialiser._();

  /// Initialises Hatch from a JSON asset file.
  static Future<void> initFromAsset(
    String assetPath, {
    HatchOptions? options,
    Map<String, String> defines = const {},
    Future<void> Function(HatchPersona?)? onPersonaChanged,
  }) async {
    // 1. Ensure Flutter binding
    WidgetsFlutterBinding.ensureInitialized();

    // 2. Load JSON from asset bundle
    final String jsonString;
    try {
      jsonString = await rootBundle.loadString(assetPath);
    } catch (e) {
      throw HatchConfigException(
        'Asset not found at path "$assetPath". '
        'If this file is gitignored, copy hatch_config.example.json and '
        'fill in local test credentials.',
      );
    }

    // 3. Parse JSON
    final Map<String, dynamic> jsonMap;
    try {
      jsonMap = json.decode(jsonString) as Map<String, dynamic>;
    } on FormatException catch (e) {
      throw HatchConfigException('Failed to parse hatch_config.json: $e');
    }

    // 4. Validate and parse config
    final config = HatchConfigParser.parse(jsonMap, defines: defines);

    // 5. Read SharedPreferences for restoration
    final prefs = await SharedPreferences.getInstance();
    final savedEnv = prefs.getString('hatch_active_env');
    final savedPersona = prefs.getString('hatch_active_persona');

    // 6. Resolve active environment
    final activeEnv = config.environments.firstWhere(
      (e) => e.name == savedEnv,
      orElse: () => config.environments.first,
    );

    // 7. Resolve active persona (search only in the active environment's personas)
    HatchPersona? resolvedPersona;
    if (savedPersona != null && savedPersona.isNotEmpty) {
      for (final p in activeEnv.personas) {
        if (p.name == savedPersona) {
          resolvedPersona = p;
          break;
        }
      }
    }

    // 8. Read dart defines
    final opts = options ?? const HatchOptions();
    final dartDefines = <String, String>{};
    for (final key in opts.dartDefineKeys) {
      // String.fromEnvironment must have a const key; at runtime we
      // cannot dynamically resolve compile-time constants. We store
      // the keys so the panel can display them. The actual resolution
      // happens at compile time in the consumer's code.
      dartDefines[key] = '';
    }

    // 9. Populate registry
    final registry = HatchRegistry.create();
    registry.environments = config.environments;
    registry.flags = config.flags;
    registry.options = opts;
    registry.dartDefines = dartDefines;
    registry.activeEnvironment = activeEnv;
    registry.activePersona = resolvedPersona;
    registry.onPersonaChanged = onPersonaChanged;
  }
}
