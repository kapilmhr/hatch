import 'package:flutter_test/flutter_test.dart';
import 'package:hatch/hatch.dart';

void main() {
  group('HatchState', () {
    final flags = [
      HatchFlag(name: 'enabled_flag', enabled: true),
      HatchFlag(name: 'disabled_flag', enabled: false),
    ];

    const env = HatchEnvironment(
      name: 'Staging',
      baseUrl: 'https://staging.api.com',
    );

    const persona = HatchPersona(
      name: 'Admin',
      role: 'admin',
    );

    test('flag() returns true for enabled flag', () {
      final state = HatchState(
        environment: env,
        persona: persona,
        flags: flags,
      );
      expect(state.flag('enabled_flag'), true);
    });

    test('flag() returns false for disabled flag', () {
      final state = HatchState(
        environment: env,
        persona: persona,
        flags: flags,
      );
      expect(state.flag('disabled_flag'), false);
    });

    test('flag() returns false for unknown flag name — never throws', () {
      final state = HatchState(
        environment: env,
        persona: persona,
        flags: flags,
      );
      expect(state.flag('nonexistent_flag'), false);
    });
  });

  group('Hatch static getters (before init)', () {
    setUp(() {
      Hatch.reset();
    });

    test('baseUrl returns empty string before initFromAsset', () {
      expect(Hatch.baseUrl, '');
    });

    test('role returns null when no persona active', () {
      expect(Hatch.role, isNull);
    });

    test('currentPersona returns null when no persona active', () {
      expect(Hatch.currentPersona, isNull);
    });

    test('flag returns false for any flag before init', () {
      expect(Hatch.flag('anything'), false);
    });
  });
}
