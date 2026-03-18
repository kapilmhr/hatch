import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../../core/hatch.dart';
import '../../../core/hatch_registry.dart';
import '../../../core/hatch_state.dart';
import '../../../models/hatch_environment.dart';
import '../../../theme/hatch_theme_data.dart';

/// The Environments tab in the Hatch panel.
class EnvironmentsTab extends StatefulWidget {
  final HatchPanelColors colors;
  final void Function(String, {bool isError}) onToast;

  const EnvironmentsTab({
    super.key,
    required this.colors,
    required this.onToast,
  });

  @override
  State<EnvironmentsTab> createState() => _EnvironmentsTabState();
}

class _EnvironmentsTabState extends State<EnvironmentsTab> {
  StreamSubscription<HatchState>? _sub;
  int? _expandedIndex;
  HatchEnvironment? _pendingDangerous;

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

  void _switchEnvironment(HatchEnvironment env) {
    if (env.isDangerous) {
      setState(() => _pendingDangerous = env);
      return;
    }
    _confirmSwitch(env);
  }

  Future<void> _confirmSwitch(HatchEnvironment env) async {
    setState(() => _pendingDangerous = null);
    await Hatch.setEnvironment(env);
    widget.onToast('✓ Switched to ${env.name}');
  }

  @override
  Widget build(BuildContext context) {
    final registry = HatchRegistry.instance;
    if (registry == null) return const SizedBox.shrink();

    final envs = registry.environments;
    final active = registry.activeEnvironment;
    final c = widget.colors;

    return Stack(
      children: [
        ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: envs.length,
          itemBuilder: (context, index) {
        final env = envs[index];
        final isActive = env.name == active.name;
        final isExpanded = _expandedIndex == index;

        return GestureDetector(
          onTap: () => _switchEnvironment(env),
          onLongPress: () {
            setState(() {
              _expandedIndex = isExpanded ? null : index;
            });
          },
          behavior: HitTestBehavior.opaque,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),

            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: isActive ? c.accentSoft : null,
              borderRadius: BorderRadius.circular(8),
              border: Border(
                left: BorderSide(
                  color: isActive ? c.accent : const Color(0x00000000),
                  width: 2,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Radio
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isActive ? c.accent : c.textTertiary,
                          width: 1.5,
                        ),
                        color: isActive ? c.accent : null,
                      ),
                      child: isActive
                          ? Center(
                              child: Container(
                                width: 4,
                                height: 4,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFFFFFFFF),
                                ),
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 8),
                    // Initial avatar
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: c.accentSoft,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        env.name.isNotEmpty ? env.name[0] : '?',
                        style: TextStyle(
                          color: c.accent,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'monospace',
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            env.name,
                            style: TextStyle(
                              color: c.textPrimary,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              decoration: TextDecoration.none,
                            ),
                          ),
                          Text(
                            env.baseUrl,
                            style: TextStyle(
                              color: c.textTertiary,
                              fontSize: 10,
                              fontFamily: 'monospace',
                              decoration: TextDecoration.none,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    if (env.isDangerous)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: c.redSoft,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'PROD',
                          style: TextStyle(
                            color: c.red,
                            fontSize: 8,
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.w700,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ),
                  ],
                ),
                // Expanded details
                if (isExpanded) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: c.surface,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          env.baseUrl,
                          style: TextStyle(
                            color: c.textSecondary,
                            fontSize: 10,
                            fontFamily: 'monospace',
                            decoration: TextDecoration.none,
                          ),
                        ),
                        if (env.headers.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          ...env.headers.entries.map((h) => Text(
                                '${h.key}: ${h.value}',
                                style: TextStyle(
                                  color: c.textTertiary,
                                  fontSize: 9,
                                  fontFamily: 'monospace',
                                  decoration: TextDecoration.none,
                                ),
                              )),
                        ],
                        const SizedBox(height: 6),
                        GestureDetector(
                          onTap: () {
                            Clipboard.setData(
                                ClipboardData(text: env.baseUrl));
                            widget.onToast('URL copied');
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: c.surfaceElevated,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Copy URL',
                              style: TextStyle(
                                color: c.accent,
                                fontSize: 9,
                                fontFamily: 'monospace',
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
        ),
        // Inline confirmation dialog for dangerous environments
        if (_pendingDangerous != null)
          GestureDetector(
            onTap: () => setState(() => _pendingDangerous = null),
            child: Container(
              color: const Color(0x73000000),
              alignment: Alignment.center,
              child: GestureDetector(
                onTap: () {}, // absorb taps so scrim tap closes
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: c.background,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: c.border),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '⚠️',
                        style: TextStyle(fontSize: 24, decoration: TextDecoration.none),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Switch to ${_pendingDangerous!.name}?',
                        style: TextStyle(
                          color: c.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'This environment points to real production data. '
                        'Actions will affect real users.',
                        style: TextStyle(
                          color: c.textSecondary,
                          fontSize: 13,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          GestureDetector(
                            onTap: () => setState(() => _pendingDangerous = null),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: c.surfaceElevated,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Cancel',
                                style: TextStyle(
                                  color: c.textSecondary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => _confirmSwitch(_pendingDangerous!),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: c.red,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'Switch',
                                style: TextStyle(
                                  color: Color(0xFFFFFFFF),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}