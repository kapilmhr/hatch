import 'package:flutter/material.dart';
import 'package:hatch/hatch.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: HatchBuilder(
        builder: (context, state) {
          return ListView(
            children: [
              _sectionHeader(theme, 'HATCH'),
              _settingsRow(
                theme,
                'Environment',
                state.environment.name,
              ),
              _settingsRow(
                theme,
                'Persona',
                state.persona?.name ?? 'Guest',
              ),
              ListTile(
                title: const Text('Open Hatch'),
                trailing: const Icon(Icons.developer_mode, size: 20),
                onTap: () => Hatch.open(),
              ),
              const Divider(),
              _sectionHeader(theme, 'APP'),
              _settingsRow(theme, 'Version', '1.0.0 (example)'),
              _settingsRow(theme, 'Build', 'debug'),
            ],
          );
        },
      ),
    );
  }

  Widget _sectionHeader(ThemeData theme, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          letterSpacing: 1.2,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _settingsRow(ThemeData theme, String label, String value) {
    return ListTile(
      title: Text(label),
      trailing: Text(
        value,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
        ),
      ),
    );
  }
}
