import 'package:flutter_test/flutter_test.dart';
import 'package:hatch/hatch.dart';
import 'package:hatch/src/config/hatch_config_exception.dart';

void main() {
  group('Hatch.initFromAsset', () {
    setUp(() {
      Hatch.reset();
    });

    tearDown(() {
      Hatch.reset();
    });

    test('throws HatchConfigException for missing asset', () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      expect(
        () => Hatch.initFromAsset('nonexistent/path.json'),
        throwsA(isA<HatchConfigException>().having(
          (e) => e.message,
          'message',
          contains('Asset not found'),
        )),
      );
    });

    test('addShortcut throws HatchStateException before init', () {
      expect(
        () => Hatch.addShortcut(
          label: 'Test',
          onTap: (_) {},
        ),
        throwsA(isA<HatchStateException>().having(
          (e) => e.message,
          'message',
          'Call Hatch.initFromAsset() before adding shortcuts.',
        )),
      );
    });
  });
}
