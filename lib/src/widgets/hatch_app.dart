import 'package:flutter/widgets.dart';

import '../core/hatch_options.dart';
import '../core/hatch_registry.dart';
import '../theme/hatch_theme_data.dart';
import 'hatch_gesture_detector.dart';
import 'hatch_overlay_entry.dart';

/// Wraps the developer's root widget to enable the Hatch overlay.
///
/// Place this at the root of your widget tree in the dev entry point:
/// ```dart
/// runApp(HatchApp(child: const MyApp()));
/// ```
///
/// The [child] widget is completely unmodified. No provider,
/// inherited widget, or state is injected into the app tree.
class HatchApp extends StatefulWidget {
  /// The root widget of the application.
  final Widget child;

  /// Creates a [HatchApp].
  const HatchApp({super.key, required this.child});

  @override
  State<HatchApp> createState() => _HatchAppState();
}

class _HatchAppState extends State<HatchApp> {
  final GlobalKey<HatchOverlayEntryState> _overlayKey =
      GlobalKey<HatchOverlayEntryState>();

  @override
  void initState() {
    super.initState();
    // Make programmatic open/close work
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final registry = HatchRegistry.instance;
      if (registry != null) {
        registry.openPanel = () => _overlayKey.currentState?.openPanel();
        registry.closePanel = () => _overlayKey.currentState?.closePanel();
      }
    });
  }

  void _openPanel() {
    _overlayKey.currentState?.openPanel();
  }

  @override
  Widget build(BuildContext context) {
    final triggers = HatchRegistry.instance?.options.triggerModes ??
        const {HatchTrigger.twoFingerLongPress};

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Stack(
        children: [
          // The app
          HatchGestureDetector(
            onTrigger: _openPanel,
            child: widget.child,
          ),
          // The overlay
          HatchOverlayEntry(key: _overlayKey),
          // FAB trigger
          if (triggers.contains(HatchTrigger.fab)) _HatchFab(onTap: _openPanel),
        ],
      ),
    );
  }
}

class _HatchFab extends StatelessWidget {
  final VoidCallback onTap;

  const _HatchFab({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final registry = HatchRegistry.instance;
    final brightness = MediaQuery.platformBrightnessOf(context);
    final theme = registry?.options.panelTheme ?? HatchTheme.system;
    final colors = HatchThemeResolver.resolve(theme, brightness);

    final persona = registry?.activePersona;
    String initials = 'H';
    if (persona != null) {
      final parts = persona.name.split(' ');
      if (parts.length >= 2) {
        initials = '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      } else if (persona.name.isNotEmpty) {
        initials = persona.name[0].toUpperCase();
      }
    }

    return Positioned(
      right: 0,
      top: 0,
      bottom: 0,
      child: SafeArea(
        child: Center(
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              width: 18,
              height: 52,
              decoration: BoxDecoration(
                color: colors.accent,
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(8),
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                initials,
                style: const TextStyle(
                  color: Color(0xFFFFFFFF),
                  fontSize: 8,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'monospace',
                  decoration: TextDecoration.none,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
