import 'package:flutter/widgets.dart';

/// Represents a screen shortcut registered via [Hatch.addShortcut].
///
/// Shortcuts are displayed in the Hatch panel and allow developers
/// to jump directly to any screen in the app.
class HatchShortcut {
  /// The label shown in the panel.
  final String label;

  /// The callback invoked when the shortcut is tapped.
  final void Function(BuildContext) onTap;

  /// An optional group name for grouping shortcuts under a shared header.
  final String? group;

  /// An optional description shown below the label.
  final String? description;

  /// An optional icon shown to the left of the label.
  final IconData? icon;

  /// Creates a new [HatchShortcut].
  const HatchShortcut({
    required this.label,
    required this.onTap,
    this.group,
    this.description,
    this.icon,
  });
}
