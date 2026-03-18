import 'package:flutter/material.dart';
import 'package:hatch/hatch.dart';

class PaywallScreen extends StatelessWidget {
  const PaywallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Upgrade to Pro')),
      body: HatchBuilder(
        builder: (context, state) {
          final role = Hatch.role;
          final isAdmin = role == 'admin';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  isAdmin ? "You have admin access" : "Upgrade to Pro",
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 24),
                if (!isAdmin) ...[
                  _featureRow(theme, 'Unlimited projects'),
                  _featureRow(theme, 'Priority support'),
                  _featureRow(theme, 'Advanced analytics'),
                  _featureRow(theme, 'Custom integrations'),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: () {
                      // Example only — does nothing
                    },
                    child: const Text('Upgrade'),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Switch to an Admin persona in Hatch to see this screen '
                    "from a privileged user's perspective",
                    style: theme.textTheme.bodySmall?.copyWith(
                      color:
                          theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ] else ...[
                  const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'You already have Pro access',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  _featureRow(theme, 'Unlimited projects'),
                  _featureRow(theme, 'Priority support'),
                  _featureRow(theme, 'Advanced analytics'),
                  _featureRow(theme, 'Custom integrations'),
                  const SizedBox(height: 16),
                  Text(
                    'Switch to a regular user persona in Hatch to test the upgrade flow',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color:
                          theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _featureRow(ThemeData theme, String feature) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.check, color: Colors.green, size: 20),
          const SizedBox(width: 8),
          Text(feature, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}
