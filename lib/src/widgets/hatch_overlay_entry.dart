import 'package:flutter/widgets.dart';

import '../core/hatch_options.dart';
import '../core/hatch_registry.dart';
import '../theme/hatch_theme_data.dart';
import 'panel/hatch_panel_shell.dart';

/// The internal overlay entry that renders the Hatch panel.
class HatchOverlayEntry extends StatefulWidget {
  const HatchOverlayEntry({super.key});

  @override
  State<HatchOverlayEntry> createState() => HatchOverlayEntryState();
}

class HatchOverlayEntryState extends State<HatchOverlayEntry>
    with SingleTickerProviderStateMixin {
  bool _isOpen = false;
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _scrimAnimation;

  HatchStyle get _style =>
      HatchRegistry.instance?.options.presentationStyle ?? HatchStyle.fullScreen;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: _style == HatchStyle.fullScreen
          ? const Duration(milliseconds: 320)
          : const Duration(milliseconds: 340),
    );
    _slideAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      ),
    );
    _scrimAnimation = Tween<double>(begin: 0.0, end: 0.4).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.875), // 280ms of 320ms
        reverseCurve: const Interval(0.0, 0.833), // 200ms of 240ms
      ),
    );

    // Register open/close callbacks
    final registry = HatchRegistry.instance;
    if (registry != null) {
      registry.openPanel = openPanel;
      registry.closePanel = () => closePanel();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void openPanel() {
    if (_isOpen) return;
    setState(() => _isOpen = true);
    _controller.duration = _style == HatchStyle.fullScreen
        ? const Duration(milliseconds: 320)
        : const Duration(milliseconds: 340);
    _controller.forward();
    HatchRegistry.instance?.isPanelOpen = true;
  }

  void closePanel({VoidCallback? onComplete}) {
    if (!_isOpen) return;
    _controller.duration = _style == HatchStyle.fullScreen
        ? const Duration(milliseconds: 240)
        : const Duration(milliseconds: 240);
    _controller.reverse().then((_) {
      if (mounted) {
        setState(() => _isOpen = false);
      }
      HatchRegistry.instance?.isPanelOpen = false;
      onComplete?.call();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isOpen && !_controller.isAnimating) {
      return const SizedBox.shrink();
    }

    final brightness = MediaQuery.platformBrightnessOf(context);
    final theme = HatchRegistry.instance?.options.panelTheme ?? HatchTheme.system;
    final colors = HatchThemeResolver.resolve(theme, brightness);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          children: [
            // Scrim
            GestureDetector(
              onTap: () => closePanel(),
              child: Container(
                color: Color.fromRGBO(0, 0, 0, _scrimAnimation.value),
              ),
            ),
            // Panel
            Positioned(
              left: 0,
              right: 0,
              top: _style == HatchStyle.bottomSheet
                  ? MediaQuery.of(context).size.height * 0.15
                  : 0,
              bottom: 0,
              child: Transform.translate(
                offset: Offset(
                  0,
                  _slideAnimation.value *
                      MediaQuery.of(context).size.height,
                ),
                child: HatchPanelShell(
                  colors: colors,
                  style: _style,
                  onClose: () => closePanel(),
                  onCloseWithCallback: (cb) => closePanel(onComplete: cb),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
