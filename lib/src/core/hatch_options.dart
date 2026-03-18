/// Trigger mode for opening the Hatch developer panel.
enum HatchTrigger {
  /// Hold two fingers for 800ms anywhere on screen.
  twoFingerLongPress,

  /// Shake the device.
  shake,

  /// Swipe inward from the right edge of the screen.
  edgeSwipe,

  /// A small pill anchored to the screen edge — always visible.
  fab,

  /// Triple-tap anywhere on screen.
  tripleClick,
}

/// Presentation style for the Hatch panel.
enum HatchStyle {
  /// Slides up to cover the full screen.
  fullScreen,

  /// Slides up from the bottom, covering 85% of the screen.
  bottomSheet,
}

/// Theme mode for the Hatch panel.
enum HatchTheme {
  /// Follows the device's brightness setting.
  system,

  /// Always uses the light theme.
  light,

  /// Always uses the dark theme.
  dark,
}

/// Configuration options for Hatch.
///
/// Pass to [Hatch.initFromAsset] to customise trigger mode,
/// presentation style, theme, and other settings.
class HatchOptions {
  /// The gesture trigger modes for opening the panel.
  ///
  /// Multiple triggers can be active simultaneously:
  /// ```dart
  /// triggerModes: {HatchTrigger.twoFingerLongPress, HatchTrigger.tripleClick}
  /// ```
  final Set<HatchTrigger> triggerModes;

  /// The presentation style of the panel.
  final HatchStyle presentationStyle;

  /// The theme of the panel.
  final HatchTheme panelTheme;

  /// Dart define keys to read via [String.fromEnvironment].
  final List<String> dartDefineKeys;

  /// Maximum number of network log entries to retain in memory.
  final int maxNetworkLogEntries;

  /// Creates [HatchOptions].
  const HatchOptions({
    this.triggerModes = const {HatchTrigger.twoFingerLongPress},
    this.presentationStyle = HatchStyle.fullScreen,
    this.panelTheme = HatchTheme.system,
    this.dartDefineKeys = const [],
    this.maxNetworkLogEntries = 50,
  });
}
