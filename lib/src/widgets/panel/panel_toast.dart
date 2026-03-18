import 'package:flutter/widgets.dart';

import '../../theme/hatch_theme_data.dart';

/// Toast notification shown at the bottom of the Hatch panel.
class PanelToast extends StatefulWidget {
  final HatchPanelColors colors;

  const PanelToast({super.key, required this.colors});

  @override
  State<PanelToast> createState() => PanelToastState();
}

class PanelToastState extends State<PanelToast>
    with SingleTickerProviderStateMixin {
  String _message = '';
  bool _isError = false;
  bool _visible = false;
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Shows a toast with the given [message].
  void show(String message, {bool isError = false}) {
    setState(() {
      _message = message;
      _isError = isError;
      _visible = true;
    });
    _controller.forward(from: 0);

    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted && _visible) {
        _controller.reverse().then((_) {
          if (mounted) {
            setState(() => _visible = false);
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_visible && !_controller.isAnimating) {
      return const SizedBox.shrink();
    }

    final c = widget.colors;
    return SlideTransition(
      position: _slideAnimation,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: c.border),
          ),
          child: Text(
            _message,
            style: TextStyle(
              color: _isError ? c.red : c.green,
              fontSize: 9,
              fontFamily: 'monospace',
              fontWeight: FontWeight.w500,
              decoration: TextDecoration.none,
            ),
          ),
        ),
      ),
    );
  }
}
