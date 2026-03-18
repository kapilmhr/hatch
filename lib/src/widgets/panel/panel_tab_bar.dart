import 'package:flutter/widgets.dart';

import '../../theme/hatch_theme_data.dart';

/// The tab bar for the Hatch panel.
class PanelTabBar extends StatelessWidget {
  final HatchPanelColors colors;
  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;

  const PanelTabBar({
    super.key,
    required this.colors,
    required this.labels,
    required this.selectedIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: Row(
        children: List.generate(labels.length, (i) {
          final isSelected = i == selectedIndex;
          return Expanded(
            child: GestureDetector(
              onTap: () => onTabSelected(i),
              behavior: HitTestBehavior.opaque,
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isSelected ? colors.accent : const Color(0x00000000),
                      width: 1.5,
                    ),
                  ),
                ),
                child: Text(
                  labels[i],
                  style: TextStyle(
                    color: isSelected ? colors.accent : colors.textTertiary,
                    fontSize: 9,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.9,
                    decoration: TextDecoration.none,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
