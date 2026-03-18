import 'package:flutter/widgets.dart';

import '../../core/hatch_options.dart';
import '../../core/hatch_registry.dart';
import '../../theme/hatch_theme_data.dart';
import 'panel_tab_bar.dart';
import 'panel_topbar.dart';
import 'panel_status_pills.dart';
import 'panel_toast.dart';
import 'tabs/environments_tab.dart';
import 'tabs/flags_tab.dart';
import 'tabs/network_tab.dart';
import 'tabs/personas_tab.dart';
import 'tabs/shortcuts_section.dart';

/// The panel shell that contains the top bar, tabs, and content.
class HatchPanelShell extends StatefulWidget {
  final HatchPanelColors colors;
  final HatchStyle style;
  final VoidCallback onClose;
  final void Function(VoidCallback) onCloseWithCallback;

  const HatchPanelShell({
    super.key,
    required this.colors,
    required this.style,
    required this.onClose,
    required this.onCloseWithCallback,
  });

  @override
  State<HatchPanelShell> createState() => _HatchPanelShellState();
}

class _HatchPanelShellState extends State<HatchPanelShell> {
  int _selectedTabIndex = 0;
  final GlobalKey<PanelToastState> _toastKey = GlobalKey<PanelToastState>();

  bool get _hasShortcuts =>
      (HatchRegistry.instance?.shortcuts.length ?? 0) >= 3;

  List<String> get _tabLabels {
    final labels = ['ENVIRONMENTS', 'PERSONAS', 'FLAGS', 'NETWORK'];
    if (_hasShortcuts) labels.add('SHORTCUTS');
    return labels;
  }

  void _showToast(String message, {bool isError = false}) {
    _toastKey.currentState?.show(message, isError: isError);
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.colors;
    final registry = HatchRegistry.instance;

    return Container(
      decoration: BoxDecoration(
        color: c.background,
        borderRadius: widget.style == HatchStyle.bottomSheet
            ? const BorderRadius.vertical(top: Radius.circular(20))
            : null,
        border: Border.all(color: c.border),
      ),
      child: SafeArea(
        top: widget.style == HatchStyle.fullScreen,
        bottom: true,
        child: Column(
          children: [
            // Drag handle for bottom sheet
            if (widget.style == HatchStyle.bottomSheet) ...[
              const SizedBox(height: 10),
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: c.textTertiary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 10),
            ],
            // Top bar
            PanelTopBar(
              colors: c,
              onClose: widget.onClose,
            ),
            // Status pills
            PanelStatusPills(colors: c),
            // Divider
            Container(height: 1, color: c.border),
            // Tab bar
            PanelTabBar(
              colors: c,
              labels: _tabLabels,
              selectedIndex: _selectedTabIndex,
              onTabSelected: (index) {
                setState(() => _selectedTabIndex = index);
              },
            ),
            Container(height: 1, color: c.border),
            // Tab content
            Expanded(
              child: Stack(
                children: [
                  _buildTabContent(registry),
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 16,
                    child: PanelToast(key: _toastKey, colors: c),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent(HatchRegistry? registry) {
    switch (_selectedTabIndex) {
      case 0:
        return EnvironmentsTab(
          colors: widget.colors,
          onToast: _showToast,
        );
      case 1:
        return PersonasTab(
          colors: widget.colors,
          onToast: _showToast,
        );
      case 2:
        return FlagsTab(
          colors: widget.colors,
          onToast: _showToast,
        );
      case 3:
        return NetworkTab(colors: widget.colors, onToast: _showToast);
      case 4:
        return ShortcutsSection(
          colors: widget.colors,
          onClose: widget.onCloseWithCallback,
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
