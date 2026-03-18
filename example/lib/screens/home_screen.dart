import 'package:flutter/material.dart';
import 'package:hatch/hatch.dart';

import 'onboarding_screen.dart';
import 'paywall_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Hatch Example'),
            HatchBuilder(
              builder: (context, state) {
                return Text(
                  '${state.environment.name} · ${state.persona?.name ?? "Guest"}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // SECTION 1 — CURRENT STATE CARD
            _buildStateCard(theme),
            const SizedBox(height: 16),

            // SECTION 2 — FEATURE FLAG GATES
            _buildFlagGates(theme),
            const SizedBox(height: 16),

            // SECTION 3 — NAVIGATION
            _buildNavGrid(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildStateCard(ThemeData theme) {
    return HatchBuilder(
      builder: (context, state) {
        return Container(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: theme.colorScheme.primary,
                width: 3,
              ),
            ),
            color: theme.colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Live Hatch State — updates when you switch in panel',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(height: 12),
              // Environment
              Text('Environment',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  )),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    state.environment.name,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      state.environment.baseUrl,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontFamily: 'monospace',
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Persona
              Text('Persona',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  )),
              const SizedBox(height: 4),
              if (state.persona != null) ...[
                Row(
                  children: [
                    Text(state.persona!.name,
                        style: theme.textTheme.bodyMedium),
                    const SizedBox(width: 8),
                    if (state.persona!.role != null)
                      _badge(state.persona!.role!,
                          theme.colorScheme.primary, theme),
                  ],
                ),
              ] else
                Text(
                  'Guest — no persona active',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              const SizedBox(height: 12),
              // Feature Flags
              Text('Feature Flags',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  )),
              const SizedBox(height: 4),
              ...state.flags.map((f) => Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Row(
                      children: [
                        Text(f.name, style: theme.textTheme.bodySmall),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: f.enabled
                                ? Colors.green.withValues(alpha: 0.15)
                                : Colors.grey.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            f.enabled ? 'ON' : 'OFF',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: f.enabled ? Colors.green : Colors.grey,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ),
        );
      },
    );
  }

  Widget _badge(String text, Color color, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildFlagGates(ThemeData theme) {
    return HatchBuilder(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Feature Flag Gates',
                style: theme.textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),

            // newDashboard
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: state.flag('newDashboard')
                    ? Colors.green.withValues(alpha: 0.1)
                    : Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                state.flag('newDashboard')
                    ? 'New dashboard is active'
                    : 'Legacy dashboard (newDashboard is off)',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: state.flag('newDashboard')
                      ? Colors.green
                      : Colors.grey,
                ),
              ),
            ),
            const SizedBox(height: 8),

            // showUpgradeBanner
            if (state.flag('showUpgradeBanner'))
              GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) => const PaywallScreen()),
                ),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Upgrade to Pro — tap to see paywall',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.amber.shade800,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 8),

            // betaSearch
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: state.flag('betaSearch')
                    ? Colors.blue.withValues(alpha: 0.1)
                    : Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                state.flag('betaSearch')
                    ? 'Beta search bar would appear here'
                    : 'betaSearch flag is off',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: state.flag('betaSearch')
                      ? Colors.blue
                      : Colors.grey,
                ),
              ),
            ),
            const SizedBox(height: 8),

            // analyticsV2
            Text(
              state.flag('analyticsV2')
                  ? 'analyticsV2: tracking with new pipeline'
                  : 'analyticsV2: using legacy pipeline',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: state.flag('analyticsV2')
                    ? Colors.green
                    : Colors.grey,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildNavGrid(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Navigation',
            style: theme.textTheme.titleSmall
                ?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _navButton(context, 'Profile', const ProfileScreen()),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _navButton(context, 'Settings', const SettingsScreen()),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _navButton(context, 'Paywall', const PaywallScreen()),
            ),
            const SizedBox(width: 8),
            Expanded(
              child:
                  _navButton(context, 'Onboarding', const OnboardingScreen()),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'These screens are also reachable via Hatch shortcuts — open the panel to try.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }

  Widget _navButton(BuildContext context, String label, Widget screen) {
    return OutlinedButton(
      onPressed: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => screen),
      ),
      child: Text(label),
    );
  }
}
