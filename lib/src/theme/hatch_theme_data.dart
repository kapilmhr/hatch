import 'package:flutter/widgets.dart';

import '../core/hatch_options.dart';

/// Holds the colour palette for the Hatch panel theme.
class HatchPanelColors {
  final Color background;
  final Color surface;
  final Color surfaceElevated;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color accent;
  final Color green;
  final Color red;
  final Color amber;

  const HatchPanelColors({
    required this.background,
    required this.surface,
    required this.surfaceElevated,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.accent,
    required this.green,
    required this.red,
    required this.amber,
  });

  /// Light theme palette.
  static const light = HatchPanelColors(
    background: Color(0xFFFFFFFF),
    surface: Color(0xFFF7F5F2),
    surfaceElevated: Color(0xFFEFECE8),
    border: Color(0x14000000), // rgba(0,0,0,0.08)
    textPrimary: Color(0xFF1A1814),
    textSecondary: Color(0xFF6B6760),
    textTertiary: Color(0xFFA8A5A0),
    accent: Color(0xFF2D5BE3),
    green: Color(0xFF1A8A4A),
    red: Color(0xFFD93025),
    amber: Color(0xFFC07800),
  );

  /// Dark theme palette.
  static const dark = HatchPanelColors(
    background: Color(0xFF111110),
    surface: Color(0xFF1A1A18),
    surfaceElevated: Color(0xFF222220),
    border: Color(0x14FFFFFF), // rgba(255,255,255,0.08)
    textPrimary: Color(0xFFF0EEE8),
    textSecondary: Color(0xFF9C9A94),
    textTertiary: Color(0xFF5C5A54),
    accent: Color(0xFF4D8FFF),
    green: Color(0xFF34C77A),
    red: Color(0xFFFF6058),
    amber: Color(0xFFFFB830),
  );

  /// Soft (10% opacity) accent colour.
  Color get accentSoft => accent.withValues(alpha: 0.1);

  /// Soft green colour.
  Color get greenSoft => green.withValues(alpha: 0.1);

  /// Soft red colour.
  Color get redSoft => red.withValues(alpha: 0.1);

  /// Soft amber colour.
  Color get amberSoft => amber.withValues(alpha: 0.1);

  /// Soft purple colour (for admin avatars / mock badges).
  Color get purple => const Color(0xFF8B5CF6);

  /// Soft purple background.
  Color get purpleSoft => purple.withValues(alpha: 0.1);
}

/// Resolves the panel colours based on the configured theme.
class HatchThemeResolver {
  const HatchThemeResolver._();

  /// Resolves the panel colours for the given [theme] and [brightness].
  static HatchPanelColors resolve(
    HatchTheme theme,
    Brightness brightness,
  ) {
    switch (theme) {
      case HatchTheme.light:
        return HatchPanelColors.light;
      case HatchTheme.dark:
        return HatchPanelColors.dark;
      case HatchTheme.system:
        return brightness == Brightness.dark
            ? HatchPanelColors.dark
            : HatchPanelColors.light;
    }
  }
}
