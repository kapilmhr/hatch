import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hatch/hatch.dart';
import 'package:hatch/src/core/hatch_registry.dart';
import 'package:hatch/src/network/hatch_interceptor.dart';

void main() {
  group('HatchInterceptor', () {
    late HatchInterceptor interceptor;

    setUp(() {
      // Set up a mock registry
      Hatch.reset();
      final registry = HatchRegistry.create();
      registry.environments = [
        const HatchEnvironment(
          name: 'Staging',
          baseUrl: 'https://staging.api.com',
          headers: {'X-Custom': 'test-value'},
        ),
      ];
      registry.activeEnvironment = registry.environments.first;
      registry.flags = [];
      registry.options = const HatchOptions();

      interceptor = HatchInterceptor();
      hatchNetworkLogStore.clear();
    });

    tearDown(() {
      Hatch.reset();
      hatchNetworkLogStore.clear();
    });

    test('replaces baseUrl with Hatch.baseUrl on each request', () {
      final options = RequestOptions(
        baseUrl: 'https://old.api.com',
        path: '/users',
      );
      final handler = _TestRequestHandler();

      interceptor.onRequest(options, handler);

      expect(handler.lastOptions!.baseUrl, 'https://staging.api.com');
    });

    test('merges environment headers into request', () {
      final options = RequestOptions(
        baseUrl: 'https://old.api.com',
        path: '/users',
      );
      final handler = _TestRequestHandler();

      interceptor.onRequest(options, handler);

      expect(handler.lastOptions!.headers['X-Custom'], 'test-value');
    });

    test('logs successful response to network store', () {
      final requestOptions = RequestOptions(
        baseUrl: 'https://staging.api.com',
        path: '/users/1',
        method: 'GET',
      );
      requestOptions.extra['hatch_start'] =
          DateTime.now().millisecondsSinceEpoch - 100;

      final response = Response(
        requestOptions: requestOptions,
        statusCode: 200,
        data: {'id': 1},
      );
      final handler = _TestResponseHandler();

      interceptor.onResponse(response, handler);

      expect(hatchNetworkLogStore.length, 1);
      final entry = hatchNetworkLogStore.entries.first;
      expect(entry.method, 'GET');
      expect(entry.statusCode, 200);
    });

    test('logs error response to network store', () {
      final requestOptions = RequestOptions(
        baseUrl: 'https://staging.api.com',
        path: '/users/1',
        method: 'GET',
      );
      requestOptions.extra['hatch_start'] =
          DateTime.now().millisecondsSinceEpoch - 100;

      final error = DioException(
        requestOptions: requestOptions,
        response: Response(
          requestOptions: requestOptions,
          statusCode: 404,
          data: 'Not found',
        ),
      );
      final handler = _TestErrorHandler();

      interceptor.onError(error, handler);

      expect(hatchNetworkLogStore.length, 1);
      final entry = hatchNetworkLogStore.entries.first;
      expect(entry.statusCode, 404);
    });

    test('records correct duration in log entry', () {
      final requestOptions = RequestOptions(
        baseUrl: 'https://staging.api.com',
        path: '/users/1',
        method: 'GET',
      );
      requestOptions.extra['hatch_start'] =
          DateTime.now().millisecondsSinceEpoch - 150;

      final response = Response(
        requestOptions: requestOptions,
        statusCode: 200,
        data: {},
      );
      final handler = _TestResponseHandler();

      interceptor.onResponse(response, handler);

      final entry = hatchNetworkLogStore.entries.first;
      // Duration should be approximately 150ms (give or take for execution time)
      expect(entry.durationMs, greaterThanOrEqualTo(100));
      expect(entry.durationMs, lessThan(1000));
    });
  });
}

class _TestRequestHandler extends RequestInterceptorHandler {
  RequestOptions? lastOptions;

  @override
  void next(RequestOptions requestOptions) {
    lastOptions = requestOptions;
  }
}

class _TestResponseHandler extends ResponseInterceptorHandler {
  @override
  void next(Response response) {}
}

class _TestErrorHandler extends ErrorInterceptorHandler {
  @override
  void next(DioException err) {}
}
