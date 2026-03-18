import 'dart:async';

import 'package:flutter/widgets.dart';

import '../core/hatch_options.dart';
import '../core/hatch_registry.dart';

/// Detects the configured gesture trigger and opens the Hatch panel.
class HatchGestureDetector extends StatefulWidget {
  final Widget child;
  final VoidCallback onTrigger;

  const HatchGestureDetector({
    super.key,
    required this.child,
    required this.onTrigger,
  });

  @override
  State<HatchGestureDetector> createState() => _HatchGestureDetectorState();
}

class _HatchGestureDetectorState extends State<HatchGestureDetector> {
  // Two-finger long press state
  final Map<int, Offset> _pointers = {};
  Timer? _longPressTimer;

  // Edge swipe state
  double? _edgeSwipeStartX;

  // Triple-click state
  int _tapCount = 0;
  Timer? _tripleClickTimer;

  Set<HatchTrigger> get _triggerModes =>
      HatchRegistry.instance?.options.triggerModes ?? const {HatchTrigger.twoFingerLongPress};

  @override
  void dispose() {
    _longPressTimer?.cancel();
    _tripleClickTimer?.cancel();
    super.dispose();
  }

  void _onPointerDown(PointerDownEvent event) {
    if (!_triggerModes.contains(HatchTrigger.twoFingerLongPress)) return;

    _pointers[event.pointer] = event.position;

    if (_pointers.length == 2) {
      _longPressTimer?.cancel();
      _longPressTimer = Timer(const Duration(milliseconds: 800), () {
        if (_pointers.length == 2) {
          widget.onTrigger();
          _pointers.clear();
        }
      });
    }
  }

  void _onPointerMove(PointerMoveEvent event) {
    if (!_triggerModes.contains(HatchTrigger.twoFingerLongPress)) return;

    final original = _pointers[event.pointer];
    if (original != null) {
      final delta = (event.position - original).distance;
      if (delta > 8.0) {
        _longPressTimer?.cancel();
        _pointers.remove(event.pointer);
      }
    }
  }

  void _onPointerUp(PointerUpEvent event) {
    if (!_triggerModes.contains(HatchTrigger.twoFingerLongPress)) return;
    _pointers.remove(event.pointer);
    if (_pointers.length < 2) {
      _longPressTimer?.cancel();
    }
  }

  void _onPointerCancel(PointerCancelEvent event) {
    if (!_triggerModes.contains(HatchTrigger.twoFingerLongPress)) return;
    _pointers.remove(event.pointer);
    if (_pointers.length < 2) {
      _longPressTimer?.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    final triggers = _triggerModes;

    Widget child = widget.child;

    // Two-finger long press detection
    if (triggers.contains(HatchTrigger.twoFingerLongPress)) {
      child = Listener(
        onPointerDown: _onPointerDown,
        onPointerMove: _onPointerMove,
        onPointerUp: _onPointerUp,
        onPointerCancel: _onPointerCancel,
        child: child,
      );
    }

    // Edge swipe detection
    if (triggers.contains(HatchTrigger.edgeSwipe)) {
      child = GestureDetector(
        behavior: HitTestBehavior.translucent,
        onHorizontalDragStart: (details) {
          final screenWidth = MediaQuery.of(context).size.width;
          if (details.globalPosition.dx > screenWidth - 24) {
            _edgeSwipeStartX = details.globalPosition.dx;
          } else {
            _edgeSwipeStartX = null;
          }
        },
        onHorizontalDragEnd: (details) {
          if (_edgeSwipeStartX != null) {
            final velocity = details.primaryVelocity ?? 0;
            if (velocity < -100) {
              widget.onTrigger();
            }
          }
          _edgeSwipeStartX = null;
        },
        child: child,
      );
    }

    // Triple-click detection
    if (triggers.contains(HatchTrigger.tripleClick)) {
      child = GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          _tapCount++;
          _tripleClickTimer?.cancel();
          if (_tapCount >= 3) {
            _tapCount = 0;
            widget.onTrigger();
          } else {
            // Reset count if no third tap arrives within 500ms
            _tripleClickTimer = Timer(const Duration(milliseconds: 500), () {
              _tapCount = 0;
            });
          }
        },
        child: child,
      );
    }

    return child;
  }
}
