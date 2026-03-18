import 'package:flutter_test/flutter_test.dart';
import 'package:hatch/src/config/hatch_config_exception.dart';
import 'package:hatch/src/config/hatch_config_parser.dart';

void main() {
  group('HatchConfigParser', () {
    test('parses valid config with all fields', () {
      final config = HatchConfigParser.parse({
        'environments': [
          {
            'name': 'Local',
            'baseUrl': 'http://localhost:3000',
            'headers': {'X-Dev': 'true'},
            'isDangerous': false,
            'personas': [
              {
                'name': 'Admin',
                'role': 'admin',
                'credentials': {
                  'email': 'admin@test.com',
                  'password': 'pass',
                  'apiToken': 'tok123',
                  'extra': {'org': 'acme'},
                },
              },
              {
                'name': 'Guest',
                'role': null,
                'credentials': null,
              },
            ],
          },
          {
            'name': 'Production',
            'baseUrl': 'https://api.example.com',
            'isDangerous': true,
          },
        ],
        'featureFlags': [
          {'name': 'flag1', 'enabled': true, 'description': 'A flag'},
          {'name': 'flag2', 'enabled': false},
        ],
      });

      expect(config.environments.length, 2);
      expect(config.environments[0].name, 'Local');
      expect(config.environments[0].baseUrl, 'http://localhost:3000');
      expect(config.environments[0].headers, {'X-Dev': 'true'});
      expect(config.environments[0].isDangerous, false);
      expect(config.environments[1].isDangerous, true);

      expect(config.flags.length, 2);
      expect(config.flags[0].name, 'flag1');
      expect(config.flags[0].enabled, true);
      expect(config.flags[0].description, 'A flag');
      expect(config.flags[1].enabled, false);

      final personas = config.environments[0].personas;
      expect(personas.length, 2);
      expect(personas[0].name, 'Admin');
      expect(personas[0].role, 'admin');
      expect(personas[0].credentials!.email, 'admin@test.com');
      expect(personas[0].credentials!.apiToken, 'tok123');
      expect(personas[0].credentials!.extra, {'org': 'acme'});
      expect(personas[1].credentials, isNull);
    });

    test('throws HatchConfigException when environments array is missing', () {
      expect(
        () => HatchConfigParser.parse({}),
        throwsA(isA<HatchConfigException>().having(
          (e) => e.message,
          'message',
          'environments must be a non-empty array.',
        )),
      );
    });

    test('throws HatchConfigException when environments array is empty', () {
      expect(
        () => HatchConfigParser.parse({'environments': []}),
        throwsA(isA<HatchConfigException>().having(
          (e) => e.message,
          'message',
          'environments must be a non-empty array.',
        )),
      );
    });

    test('throws HatchConfigException when environment is missing name', () {
      expect(
        () => HatchConfigParser.parse({
          'environments': [
            {'baseUrl': 'http://localhost'},
          ],
        }),
        throwsA(isA<HatchConfigException>().having(
          (e) => e.message,
          'message',
          'Environment at index 0 is missing required field "name".',
        )),
      );
    });

    test('throws HatchConfigException when environment is missing baseUrl',
        () {
      expect(
        () => HatchConfigParser.parse({
          'environments': [
            {'name': 'Local'},
          ],
        }),
        throwsA(isA<HatchConfigException>().having(
          (e) => e.message,
          'message',
          'Environment at index 0 is missing required field "baseUrl".',
        )),
      );
    });

    test('throws HatchConfigException on duplicate environment names', () {
      expect(
        () => HatchConfigParser.parse({
          'environments': [
            {'name': 'Local', 'baseUrl': 'http://localhost:3000'},
            {'name': 'Local', 'baseUrl': 'http://localhost:4000'},
          ],
        }),
        throwsA(isA<HatchConfigException>().having(
          (e) => e.message,
          'message',
          'Duplicate environment name "Local".',
        )),
      );
    });

    test('throws HatchConfigException on duplicate persona names', () {
      expect(
        () => HatchConfigParser.parse({
          'environments': [
            {
              'name': 'Local',
              'baseUrl': 'http://localhost:3000',
              'personas': [
                {'name': 'Admin', 'role': 'admin'},
                {'name': 'Admin', 'role': 'user'},
              ],
            },
          ],
        }),
        throwsA(isA<HatchConfigException>().having(
          (e) => e.message,
          'message',
          'Duplicate persona name "Admin" in environment "Local".',
        )),
      );
    });

    test('parses persona with null credentials', () {
      final config = HatchConfigParser.parse({
        'environments': [
          {
            'name': 'Local',
            'baseUrl': 'http://localhost:3000',
            'personas': [
              {'name': 'Guest', 'credentials': null},
            ],
          },
        ],
      });

      expect(config.environments[0].personas[0].credentials, isNull);
    });

    test('parses persona with null role', () {
      final config = HatchConfigParser.parse({
        'environments': [
          {
            'name': 'Local',
            'baseUrl': 'http://localhost:3000',
            'personas': [
              {'name': 'Guest', 'role': null},
            ],
          },
        ],
      });

      expect(config.environments[0].personas[0].role, isNull);
    });

    test('defaults isDangerous to false when omitted', () {
      final config = HatchConfigParser.parse({
        'environments': [
          {'name': 'Local', 'baseUrl': 'http://localhost:3000'},
        ],
      });

      expect(config.environments[0].isDangerous, false);
    });

    test('defaults headers to empty map when omitted', () {
      final config = HatchConfigParser.parse({
        'environments': [
          {'name': 'Local', 'baseUrl': 'http://localhost:3000'},
        ],
      });

      expect(config.environments[0].headers, isEmpty);
    });

    test('parses feature flags correctly', () {
      final config = HatchConfigParser.parse({
        'environments': [
          {'name': 'Local', 'baseUrl': 'http://localhost:3000'},
        ],
        'featureFlags': [
          {'name': 'darkMode', 'enabled': true, 'description': 'Dark theme'},
          {'name': 'newUI', 'enabled': false},
        ],
      });

      expect(config.flags.length, 2);
      expect(config.flags[0].name, 'darkMode');
      expect(config.flags[0].enabled, true);
      expect(config.flags[0].description, 'Dark theme');
      expect(config.flags[1].name, 'newUI');
      expect(config.flags[1].enabled, false);
      expect(config.flags[1].description, isNull);
    });

    test('handles empty personas array in environment', () {
      final config = HatchConfigParser.parse({
        'environments': [
          {
            'name': 'Local',
            'baseUrl': 'http://localhost:3000',
            'personas': [],
          },
        ],
      });

      expect(config.environments[0].personas, isEmpty);
    });

    test('handles empty featureFlags array', () {
      final config = HatchConfigParser.parse({
        'environments': [
          {'name': 'Local', 'baseUrl': 'http://localhost:3000'},
        ],
        'featureFlags': [],
      });

      expect(config.flags, isEmpty);
    });

    test('resolves \$VAR placeholders from defines', () {
      final config = HatchConfigParser.parse(
        {
          'environments': [
            {
              'name': 'Staging',
              'baseUrl': r'$STAGING_BASE_URL',
              'headers': {
                'X-Token': r'$API_TOKEN',
              },
              'personas': [
                {
                  'name': 'Admin',
                  'role': 'admin',
                  'credentials': {
                    'email': r'$ADMIN_EMAIL',
                    'password': r'$ADMIN_PASSWORD',
                  },
                },
              ],
            },
          ],
        },
        defines: const {
          'STAGING_BASE_URL': 'https://staging.example.com',
          'API_TOKEN': 'abc123',
          'ADMIN_EMAIL': 'admin@example.com',
          'ADMIN_PASSWORD': 'secret',
        },
      );

      expect(config.environments[0].baseUrl, 'https://staging.example.com');
      expect(config.environments[0].headers['X-Token'], 'abc123');
      expect(config.environments[0].personas[0].credentials!.email,
          'admin@example.com');
      expect(config.environments[0].personas[0].credentials!.password, 'secret');
    });

    test('keeps unresolved \$VAR values as-is', () {
      final config = HatchConfigParser.parse({
        'environments': [
          {
            'name': 'Staging',
            'baseUrl': r'$MISSING_BASE_URL',
          },
        ],
      });

      expect(config.environments[0].baseUrl, r'$MISSING_BASE_URL');
    });
  });
}
