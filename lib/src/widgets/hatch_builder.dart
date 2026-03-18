import 'dart:async';

import 'package:flutter/widgets.dart';

import '../core/hatch_registry.dart';
import '../core/hatch_state.dart';

/// A widget that rebuilds when the Hatch state changes.
///
/// Subscribes to [Hatch.stream] and calls [setState] on each emission.
/// Use this to reactively display the current environment, persona,
/// or feature flag states.
///
/// ```dart
/// HatchBuilder(
///   builder: (context, state) {
///     return Text('Environment: ${state.environment.name}');
///   },
/// )
/// ```
class HatchBuilder extends StatefulWidget {
  /// The builder function called with the current [HatchState].
  final Widget Function(BuildContext, HatchState) builder;

  /// Creates a [HatchBuilder].
  const HatchBuilder({super.key, required this.builder});

  @override
  State<HatchBuilder> createState() => _HatchBuilderState();
}

class _HatchBuilderState extends State<HatchBuilder> {
  StreamSubscription<HatchState>? _sub;
  HatchState? _lastState;

  @override
  void initState() {
    super.initState();
    _lastState = HatchRegistry.instance?.currentState;
    _sub = HatchRegistry.instance?.stream.listen((state) {
      if (mounted) {
        setState(() => _lastState = state);
      }
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = _lastState ?? HatchRegistry.instance?.currentState;
    if (state == null) return const SizedBox.shrink();
    return widget.builder(context, state);
  }
}
