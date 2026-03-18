import 'dart:async';
import 'dart:collection';

/// A single network log entry.
class NetworkLogEntry {
  /// The HTTP method (GET, POST, etc.).
  final String method;

  /// The full URL of the request.
  final String fullUrl;

  /// The path only, no base URL, no query string.
  final String path;

  /// The HTTP status code, or `null` if the request failed.
  final int? statusCode;

  /// The request body.
  final dynamic requestBody;

  /// The response body.
  final dynamic responseBody;

  /// The request headers.
  final Map<String, dynamic> requestHeaders;

  /// The response headers.
  final Map<String, dynamic> responseHeaders;

  /// The duration of the request in milliseconds.
  final int durationMs;

  /// When the request was made.
  final DateTime timestamp;

  /// Whether the response came from a mock.
  final bool isMock;

  NetworkLogEntry({
    required this.method,
    required this.fullUrl,
    required this.path,
    this.statusCode,
    this.requestBody,
    this.responseBody,
    this.requestHeaders = const {},
    this.responseHeaders = const {},
    required this.durationMs,
    required this.timestamp,
    this.isMock = false,
  });
}

/// Ring buffer that stores network log entries.
///
/// Drops the oldest entry when the buffer is full.
/// Never written to disk.
class NetworkLogStore {
  NetworkLogStore({this.maxEntries = 50});

  /// Maximum number of entries to retain.
  final int maxEntries;

  final ListQueue<NetworkLogEntry> _entries = ListQueue<NetworkLogEntry>();

  final StreamController<List<NetworkLogEntry>> _controller =
      StreamController<List<NetworkLogEntry>>.broadcast();

  /// Adds a new log entry.
  void add(NetworkLogEntry entry) {
    if (_entries.length >= maxEntries) {
      _entries.removeFirst();
    }
    _entries.addLast(entry);
    _controller.add(List.unmodifiable(_entries.toList().reversed));
  }

  /// Clears all entries.
  void clear() {
    _entries.clear();
    _controller.add([]);
  }

  /// Stream of log entries, newest first.
  Stream<List<NetworkLogEntry>> get stream => _controller.stream;

  /// Current entries, newest first.
  List<NetworkLogEntry> get entries =>
      List.unmodifiable(_entries.toList().reversed);

  /// Number of entries currently stored.
  int get length => _entries.length;
}
