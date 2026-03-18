import 'package:dio/dio.dart';

import '../core/hatch.dart';
import '../core/hatch_registry.dart';
import 'network_log_store.dart';

/// Global network log store used by Hatch interceptors.
final hatchNetworkLogStore = NetworkLogStore();

/// Dio interceptor that integrates with Hatch.
///
/// Replaces the base URL with the active Hatch environment,
/// merges environment headers, and logs requests to the
/// Hatch network panel.
///
/// Usage:
/// ```dart
/// final dio = Dio();
/// dio.interceptors.add(HatchInterceptor());
/// ```
class HatchInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // 1. Replace baseUrl with Hatch.baseUrl (reflects current env)
    options.baseUrl = Hatch.baseUrl;

    // 2. Merge environment headers
    Hatch.currentEnvironment.headers.forEach((k, v) {
      options.headers[k] = v;
    });

    // 3. Record request start time
    options.extra['hatch_start'] = DateTime.now().millisecondsSinceEpoch;

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _logRequest(response.requestOptions, response.statusCode, response.data,
        responseHeaders: response.headers.map);
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _logRequest(
      err.requestOptions,
      err.response?.statusCode ?? 0,
      err.response?.data,
      responseHeaders: err.response?.headers.map ?? {},
    );
    handler.next(err);
  }

  void _logRequest(
    RequestOptions options,
    int? statusCode,
    dynamic responseBody, {
    Map<String, List<String>> responseHeaders = const {},
  }) {
    final startMs = options.extra['hatch_start'] as int?;
    final durationMs = startMs != null
        ? DateTime.now().millisecondsSinceEpoch - startMs
        : 0;

    final uri = options.uri;
    final path = uri.path.isEmpty ? '/' : uri.path;

    final maxEntries =
        HatchRegistry.instance?.options.maxNetworkLogEntries ?? 50;
    if (hatchNetworkLogStore.maxEntries != maxEntries) {
      // Respect the configured max entries
    }

    hatchNetworkLogStore.add(NetworkLogEntry(
      method: options.method,
      fullUrl: uri.toString(),
      path: path,
      statusCode: statusCode,
      requestBody: options.data,
      responseBody: responseBody,
      requestHeaders: Map<String, dynamic>.from(options.headers),
      responseHeaders: responseHeaders.map(
        (k, v) => MapEntry(k, v.join(', ')),
      ),
      durationMs: durationMs,
      timestamp: DateTime.now(),
    ));
  }
}
