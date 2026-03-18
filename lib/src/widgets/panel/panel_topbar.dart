import 'package:flutter/widgets.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../theme/hatch_theme_data.dart';

/// The top bar of the Hatch panel.
class PanelTopBar extends StatefulWidget {
  final HatchPanelColors colors;
  final VoidCallback onClose;

  const PanelTopBar({
    super.key,
    required this.colors,
    required this.onClose,
  });

  @override
  State<PanelTopBar> createState() => _PanelTopBarState();
}

class _PanelTopBarState extends State<PanelTopBar> {
  String _version = '';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() => _version = 'v${info.version}');
      }
    } catch (_) {
      // PackageInfo may not resolve in tests
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.colors;
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
            'hatch',
            style: TextStyle(
              color: c.accent,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              fontFamily: 'monospace',
              decoration: TextDecoration.none,
            ),
          ),
          const Spacer(),
          if (_version.isNotEmpty) ...[
            Text(
              _version,
              style: TextStyle(
                color: c.textTertiary,
                fontSize: 10,
                fontFamily: 'monospace',
                decoration: TextDecoration.none,
              ),
            ),
            const SizedBox(width: 12),
          ],
          GestureDetector(
            onTap: widget.onClose,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: c.surfaceElevated,
              ),
              alignment: Alignment.center,
              child: Text(
                '✕',
                style: TextStyle(
                  color: c.textSecondary,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
