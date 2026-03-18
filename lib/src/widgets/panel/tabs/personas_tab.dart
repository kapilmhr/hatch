import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../../core/hatch.dart';
import '../../../core/hatch_registry.dart';
import '../../../core/hatch_state.dart';
import '../../../models/hatch_persona.dart';
import '../../../theme/hatch_theme_data.dart';

/// The Personas tab in the Hatch panel.
class PersonasTab extends StatefulWidget {
  final HatchPanelColors colors;
  final void Function(String, {bool isError}) onToast;

  const PersonasTab({
    super.key,
    required this.colors,
    required this.onToast,
  });

  @override
  State<PersonasTab> createState() => _PersonasTabState();
}

class _PersonasTabState extends State<PersonasTab> {
  StreamSubscription<HatchState>? _sub;
  int? _expandedIndex;
  final Map<int, bool> _showPassword = {};

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

  String _getInitials(String name) {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  Color _getAvatarBg(HatchPanelColors c, HatchPersona persona) {
    if (persona.role == null) return c.surfaceElevated;
    return _roleColors(c, persona.role!).$1;
  }

  Color _getAvatarText(HatchPanelColors c, HatchPersona persona) {
    if (persona.role == null) return c.textTertiary;
    return _roleColors(c, persona.role!).$2;
  }

  /// Returns (background, foreground) for a given role string.
  /// Same role always maps to the same color pair.
  (Color, Color) _roleColors(HatchPanelColors c, String role) {
    final palette = [
      (c.accentSoft, c.accent),
      (c.purpleSoft, c.purple),
      (c.amberSoft, c.amber),
      (c.greenSoft, c.green),
      (c.redSoft, c.red),
    ];
    final hash = role.codeUnits.fold(0, (sum, cu) => sum + cu);
    return palette[hash % palette.length];
  }

  Future<void> _switchPersona(HatchPersona? persona) async {
    await Hatch.setPersona(persona);
    widget.onToast('✓ ${persona?.name ?? "Guest"} active');
  }

  @override
  Widget build(BuildContext context) {
    final registry = HatchRegistry.instance;
    if (registry == null) return const SizedBox.shrink();

    final c = widget.colors;
    final personas = registry.activeEnvironment.personas;
    final active = registry.activePersona;

    // Group by role
    final groups = <String, List<MapEntry<int, HatchPersona>>>{};
    for (var i = 0; i < personas.length; i++) {
      final p = personas[i];
      if (p.credentials == null && p.role == null) continue; // Guest handled separately
      final groupName = p.role != null
          ? p.role![0].toUpperCase() + p.role!.substring(1)
          : 'Other';
      groups.putIfAbsent(groupName, () => []);
      groups[groupName]!.add(MapEntry(i, p));
    }

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 4),
      children: [
        for (final group in groups.entries) ...[
          _buildGroupHeader(c, group.key, group.value.length),
          for (final entry in group.value)
            _buildPersonaRow(
              c,
              entry.key,
              entry.value,
              entry.value.name == active?.name,
            ),
        ],
        // Guest row always last
        _buildGuestRow(c, active == null),
      ],
    );
  }

  Widget _buildGroupHeader(HatchPanelColors c, String name, int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          Text(
            name.toUpperCase(),
            style: TextStyle(
              color: c.textTertiary,
              fontSize: 8,
              fontFamily: 'monospace',
              fontWeight: FontWeight.w700,
              letterSpacing: 1.44,
              decoration: TextDecoration.none,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
            decoration: BoxDecoration(
              color: c.surface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                color: c.textTertiary,
                fontSize: 8,
                fontFamily: 'monospace',
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonaRow(
      HatchPanelColors c, int index, HatchPersona persona, bool isActive) {
    final isExpanded = _expandedIndex == index;

    return GestureDetector(
      onTap: () => _switchPersona(persona),
      onLongPress: () {
        setState(() {
          _expandedIndex = isExpanded ? null : index;
        });
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? c.greenSoft : null,
          borderRadius: BorderRadius.circular(8),
          border: Border(
            left: BorderSide(
              color: isActive ? c.green : const Color(0x00000000),
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
                      color: isActive ? c.green : c.textTertiary,
                      width: 1.5,
                    ),
                    color: isActive ? c.green : null,
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
                // Avatar
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _getAvatarBg(c, persona),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _getInitials(persona.name),
                    style: TextStyle(
                      color: _getAvatarText(c, persona),
                      fontSize: 9,
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
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              persona.name,
                              style: TextStyle(
                                color: c.textPrimary,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                decoration: TextDecoration.none,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isActive) ...[
                            const SizedBox(width: 6),
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: c.green,
                              ),
                            ),
                          ],
                        ],
                      ),
                      Row(
                        children: [
                          if (persona.role != null) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 4, vertical: 1),
                              decoration: BoxDecoration(
                                color: _roleColors(c, persona.role!).$1,
                                borderRadius: BorderRadius.circular(3),
                              ),
                              child: Text(
                                persona.role!,
                                style: TextStyle(
                                  color: _roleColors(c, persona.role!).$2,
                                  fontSize: 7,
                                  fontFamily: 'monospace',
                                  fontWeight: FontWeight.w700,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                          ],
                          if (persona.tag != null) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 4, vertical: 1),
                              decoration: BoxDecoration(
                                color: c.surfaceElevated,
                                borderRadius: BorderRadius.circular(3),
                              ),
                              child: Text(
                                persona.tag!,
                                style: TextStyle(
                                  color: c.textSecondary,
                                  fontSize: 7,
                                  fontFamily: 'monospace',
                                  fontWeight: FontWeight.w600,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                if (persona.credentials?.email != null)
                  Text(
                    persona.credentials!.email,
                    style: TextStyle(
                      color: c.textTertiary,
                      fontSize: 8,
                      fontFamily: 'monospace',
                      decoration: TextDecoration.none,
                    ),
                  ),
              ],
            ),
            // Expanded details on long press
            if (isExpanded && persona.credentials != null) ...[
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
                    _detailRow(c, 'Email', persona.credentials!.email),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: _detailRow(
                            c,
                            'Password',
                            (_showPassword[index] ?? false)
                                ? persona.credentials!.password
                                : '••••••••',
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _showPassword[index] =
                                  !(_showPassword[index] ?? false);
                            });
                          },
                          child: Text(
                            (_showPassword[index] ?? false) ? '🙈' : '👁',
                            style: const TextStyle(
                              fontSize: 12,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (persona.role != null) ...[
                      const SizedBox(height: 4),
                      _detailRow(c, 'Role', persona.role!),
                    ],
                    if (persona.tag != null) ...[
                      const SizedBox(height: 4),
                      _detailRow(c, 'Tag', persona.tag!),
                    ],

                    const SizedBox(height: 6),
                    GestureDetector(
                      onTap: () {
                        final data = json.encode({
                          'email': persona.credentials!.email,
                          'password': persona.credentials!.password,
                        });
                        Clipboard.setData(ClipboardData(text: data));
                        widget.onToast('Credentials copied');
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: c.surfaceElevated,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Copy credentials',
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
  }

  Widget _detailRow(HatchPanelColors c, String label, String value) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: TextStyle(
            color: c.textTertiary,
            fontSize: 9,
            fontFamily: 'monospace',
            decoration: TextDecoration.none,
          ),
        ),
        Flexible(
          child: Text(
            value,
            style: TextStyle(
              color: c.textSecondary,
              fontSize: 9,
              fontFamily: 'monospace',
              decoration: TextDecoration.none,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildGuestRow(HatchPanelColors c, bool isActive) {
    return GestureDetector(
      onTap: () => _switchPersona(null),
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? c.greenSoft : null,
          borderRadius: BorderRadius.circular(8),
          border: Border(
            left: BorderSide(
              color: isActive ? c.green : const Color(0x00000000),
              width: 2,
            ),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isActive ? c.green : c.textTertiary,
                  width: 1.5,
                ),
                color: isActive ? c.green : null,
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
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: c.surfaceElevated,
              ),
              alignment: Alignment.center,
              child: Text(
                'G',
                style: TextStyle(
                  color: c.textTertiary,
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'monospace',
                  decoration: TextDecoration.none,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Guest (No Auth)',
              style: TextStyle(
                color: c.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                decoration: TextDecoration.none,
              ),
            ),
            if (isActive) ...[
              const SizedBox(width: 6),
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: c.green,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
