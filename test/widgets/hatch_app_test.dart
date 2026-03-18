import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hatch/hatch.dart';
import 'package:hatch/src/core/hatch_registry.dart';

void main() {
  group('HatchApp', () {
    setUp(() {
      Hatch.reset();
      final registry = HatchRegistry.create();
      registry.environments = [
        const HatchEnvironment(
          name: 'Test',
          baseUrl: 'https://test.api.com',
        ),
      ];
      registry.activeEnvironment = registry.environments.first;
      registry.flags = [];
      registry.options = const HatchOptions();
    });

    tearDown(() {
      Hatch.reset();
    });

    testWidgets('renders child widget', (tester) async {
      await tester.pumpWidget(
        const HatchApp(
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Text('Hello Hatch'),
          ),
        ),
      );

      expect(find.text('Hello Hatch'), findsOneWidget);
    });
  });
}
