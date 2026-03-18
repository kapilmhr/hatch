import 'package:flutter/widgets.dart';

import '../../../core/hatch_registry.dart';
import '../../../models/hatch_shortcut.dart';
import '../../../theme/hatch_theme_data.dart';

/// The Shortcuts section/tab in the Hatch panel.
class ShortcutsSection extends StatelessWidget {
  final HatchPanelColors colors;
  final void Function(VoidCallback) onClose;

  const ShortcutsSection({
    super.key,
    required this.colors,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final registry = HatchRegistry.instance;
    if (registry == null) return const SizedBox.shrink();

    final shortcuts = registry.shortcuts;
    if (shortcuts.isEmpty) return const SizedBox.shrink();

    final c = colors;

    // Group shortcuts by group
    final groups = <String?, List<HatchShortcut>>{};
    for (final s in shortcuts) {
      groups.putIfAbsent(s.group, () => []);
      groups[s.group]!.add(s);
    }

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        for (final entry in groups.entries) ...[
          if (entry.key != null)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Text(
                entry.key!.toUpperCase(),
                style: TextStyle(
                  color: c.textTertiary,
                  fontSize: 8,
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.44,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
          for (final shortcut in entry.value)
            GestureDetector(
              onTap: () {
                onClose(() {
                  if (context.mounted) {
                    shortcut.onTap(context);
                  }
                });
              },
              behavior: HitTestBehavior.opaque,
              child: Container(
                margin:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10),
                child: Row(
                  children: [
                    if (shortcut.icon != null) ...[
                      Icon(
                        shortcut.icon,
                        size: 16,
                        color: c.textSecondary,
                      ),
                      const SizedBox(width: 8),
                    ] else ...[
                      Text(
                        '→',
                        style: TextStyle(
                          color: c.textTertiary,
                          fontSize: 14,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            shortcut.label,
                            style: TextStyle(
                              color: c.textPrimary,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              decoration: TextDecoration.none,
                            ),
                          ),
                          if (shortcut.description != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              shortcut.description!,
                              style: TextStyle(
                                color: c.textTertiary,
                                fontSize: 9,
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Text(
                      '→',
                      style: TextStyle(
                        color: c.textTertiary,
                        fontSize: 14,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ],
    );
  }
}
