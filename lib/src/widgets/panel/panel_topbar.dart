import 'package:flutter/material.dart';

import '../../theme/hatch_theme_data.dart';

/// The top bar of the Hatch panel.
class PanelTopBar extends StatelessWidget {
  final HatchPanelColors colors;
  final VoidCallback onClose;

  const PanelTopBar({
    super.key,
    required this.colors,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final c = colors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          // Logo
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: c.accent,
              borderRadius: BorderRadius.circular(4),
            ),
            alignment: Alignment.center,
            child: const Text(
              'H',
              style: TextStyle(
                color: Color(0xFFFFFFFF),
                fontSize: 11,
                fontWeight: FontWeight.w700,
                fontFamily: 'monospace',
                decoration: TextDecoration.none,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Hatch',
            style: TextStyle(
              color: c.accent,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              fontFamily: 'monospace',
              decoration: TextDecoration.none,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: onClose,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: c.surfaceElevated,
                border: Border.all(color: c.textTertiary, width: 1),
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.close,
                color: c.textSecondary,
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
