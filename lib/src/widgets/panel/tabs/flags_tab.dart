import 'dart:async';

import 'package:flutter/widgets.dart';

import '../../../core/hatch.dart';
import '../../../core/hatch_registry.dart';
import '../../../core/hatch_state.dart';
import '../../../theme/hatch_theme_data.dart';

/// The Flags tab in the Hatch panel.
class FlagsTab extends StatefulWidget {
  final HatchPanelColors colors;
  final void Function(String, {bool isError}) onToast;

  const FlagsTab({
    super.key,
    required this.colors,
    required this.onToast,
  });

  @override
  State<FlagsTab> createState() => _FlagsTabState();
}

class _FlagsTabState extends State<FlagsTab> {
  StreamSubscription<HatchState>? _sub;

  @override
  void initState() {
    super.initState();
    _sub = HatchRegistry.instance?.stream.listen((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final registry = HatchRegistry.instance;
    if (registry == null) return const SizedBox.shrink();

    final c = widget.colors;
    final flags = registry.flags;

    if (flags.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'No feature flags defined.\nAdd them to hatch_config.json.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: c.textTertiary,
              fontSize: 11,
              fontFamily: 'monospace',
              decoration: TextDecoration.none,
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: flags.length,
      itemBuilder: (context, index) {
        final flag = flags[index];
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      flag.name,
                      style: TextStyle(
                        color: c.textSecondary,
                        fontSize: 10,
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w500,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    if (flag.description != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        flag.description!,
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
              GestureDetector(
                onTap: () {
                  Hatch.toggleFlag(flag.name);
                  final newState = flag.enabled;
                  widget.onToast(
                    newState
                        ? '✓ ${flag.name} enabled'
                        : '✗ ${flag.name} disabled',
                    isError: !newState,
                  );
                },
                child: _FlagToggle(
                  enabled: flag.enabled,
                  colors: c,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _FlagToggle extends StatelessWidget {
  final bool enabled;
  final HatchPanelColors colors;

  const _FlagToggle({required this.enabled, required this.colors});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeInOut,
      width: 32,
      height: 18,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(9),
        color: enabled ? colors.accent : colors.surfaceElevated,
      ),
      child: AnimatedAlign(
        duration: const Duration(milliseconds: 180),
        curve: const Cubic(0.34, 1.56, 0.64, 1),
        alignment: enabled ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
            width: 14,
            height: 14,
            margin: const EdgeInsets.all(2),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFFFFFFF),
            ),
          ),
      ),
    );
  }
}
