import 'package:http/http.dart' as http;

import '../core/hatch.dart';
import 'hatch_interceptor.dart' show hatchNetworkLogStore;
import 'network_log_store.dart';

/// An HTTP client wrapper that integrates with Hatch.
///
/// Rebuilds request URIs using the active Hatch environment base URL,
/// merges environment headers, and logs requests to the Hatch network panel.
///
/// Usage:
/// ```dart
/// final client = HatchHttpClient(http.Client());
/// final response = await client.get(Uri.parse('/users/1'));
/// ```
class HatchHttpClient extends http.BaseClient {
  /// Creates a [HatchHttpClient] wrapping the given [inner] client.
  HatchHttpClient(this._inner);

  final http.Client _inner;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    // 1. Rebuild URI using Hatch.baseUrl as base
    final baseUrl = Hatch.baseUrl;
    final newUri = Uri.parse('$baseUrl${request.url.path}');

    final newRequest = http.Request(request.method, newUri);

    // Copy headers from original request
    newRequest.headers.addAll(request.headers);

    // 2. Merge environment headers
    Hatch.currentEnvironment.headers.forEach((k, v) {
      newRequest.headers[k] = v;
    });

    // Copy body if it's a regular request
    if (request is http.Request && request.body.isNotEmpty) {
      newRequest.body = request.body;
    }

    // 3. Record start time
    final startMs = DateTime.now().millisecondsSinceEpoch;

    // 4. Forward to inner client
    final response = await _inner.send(newRequest);

    // 5. Log to ring buffer
    final durationMs = DateTime.now().millisecondsSinceEpoch - startMs;
    final path = newUri.path.isEmpty ? '/' : newUri.path;

    hatchNetworkLogStore.add(NetworkLogEntry(
      method: request.method,
      fullUrl: newUri.toString(),
      path: path,
      statusCode: response.statusCode,
      requestBody: request is http.Request ? request.body : null,
      responseBody: null, // streamed response — body not captured
      requestHeaders: Map<String, dynamic>.from(newRequest.headers),
      responseHeaders: Map<String, dynamic>.from(response.headers),
      durationMs: durationMs,
      timestamp: DateTime.now(),
    ));

    return response;
  }
}
