import 'dart:async';

import 'package:flutter/widgets.dart';

import '../../core/hatch_registry.dart';
import '../../core/hatch_state.dart';
import '../../theme/hatch_theme_data.dart';

/// Status pills showing the active environment and persona.
class PanelStatusPills extends StatefulWidget {
  final HatchPanelColors colors;

  const PanelStatusPills({super.key, required this.colors});

  @override
  State<PanelStatusPills> createState() => _PanelStatusPillsState();
}

class _PanelStatusPillsState extends State<PanelStatusPills> {
  StreamSubscription<HatchState>? _sub;
  String _envName = '';
  String _personaName = 'Guest';

  @override
  void initState() {
    super.initState();
    _updateFromRegistry();
    _sub = HatchRegistry.instance?.stream.listen((_) {
      _updateFromRegistry();
    });
  }

  void _updateFromRegistry() {
    final registry = HatchRegistry.instance;
    if (registry == null) return;
    if (mounted) {
      setState(() {
        _envName = registry.activeEnvironment.name;
        _personaName = registry.activePersona?.name ?? 'Guest';
      });
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          _buildPill(c, c.accent, _envName),
          const SizedBox(width: 8),
          _buildPill(c, c.green, _personaName),
        ],
      ),
    );
  }

  Widget _buildPill(HatchPanelColors c, Color dotColor, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: c.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: dotColor,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: c.textPrimary,
              fontSize: 9,
              fontFamily: 'monospace',
              fontWeight: FontWeight.w500,
              decoration: TextDecoration.none,
            ),
          ),
        ],
      ),
    );
  }
}
