import 'dart:async';
import 'dart:convert';

import 'package:flutter/widgets.dart';

import '../../../network/hatch_interceptor.dart' show hatchNetworkLogStore;
import '../../../network/network_log_store.dart';
import '../../../theme/hatch_theme_data.dart';

/// The Network tab in the Hatch panel.
class NetworkTab extends StatefulWidget {
  final HatchPanelColors colors;
  final void Function(String, {bool isError}) onToast;

  const NetworkTab({super.key, required this.colors, required this.onToast});

  @override
  State<NetworkTab> createState() => _NetworkTabState();
}

class _NetworkTabState extends State<NetworkTab> {
  StreamSubscription<List<NetworkLogEntry>>? _sub;
  List<NetworkLogEntry> _entries = [];
  int? _expandedIndex;

  @override
  void initState() {
    super.initState();
    _entries = hatchNetworkLogStore.entries;
    _sub = hatchNetworkLogStore.stream.listen((entries) {
      if (mounted) {
        setState(() => _entries = entries);
      }
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  Color _methodColor(HatchPanelColors c, String method) {
    switch (method.toUpperCase()) {
      case 'GET':
        return c.accent;
      case 'POST':
        return c.green;
      case 'PATCH':
      case 'PUT':
        return c.amber;
      case 'DELETE':
        return c.red;
      default:
        return c.textSecondary;
    }
  }

  Color _methodBg(HatchPanelColors c, String method) {
    switch (method.toUpperCase()) {
      case 'GET':
        return c.accentSoft;
      case 'POST':
        return c.greenSoft;
      case 'PATCH':
      case 'PUT':
        return c.amberSoft;
      case 'DELETE':
        return c.redSoft;
      default:
        return c.surface;
    }
  }

  Color _statusColor(HatchPanelColors c, int? code) {
    if (code == null || code == 0) return c.textTertiary;
    if (code >= 200 && code < 300) return c.green;
    if (code >= 300 && code < 400) return c.accent;
    if (code >= 400 && code < 500) return c.amber;
    return c.red;
  }

  String _relativeTime(DateTime timestamp) {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    return '${diff.inHours}h ago';
  }

  String _prettyJson(dynamic data) {
    if (data == null) return '';
    try {
      if (data is String) {
        final parsed = json.decode(data);
        return const JsonEncoder.withIndent('  ').convert(parsed);
      }
      return const JsonEncoder.withIndent('  ').convert(data);
    } catch (_) {
      return data.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.colors;

    return Column(
      children: [
        // Section header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Text(
                'NETWORK LOG (${_entries.length})',
                style: TextStyle(
                  color: c.textTertiary,
                  fontSize: 8,
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.44,
                  decoration: TextDecoration.none,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  hatchNetworkLogStore.clear();
                  widget.onToast('Log cleared');
                },
                child: Text(
                  'Clear',
                  style: TextStyle(
                    color: c.accent,
                    fontSize: 9,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Entries
        Expanded(
          child: _entries.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'No requests yet.\nAdd HatchInterceptor to your Dio instance.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: c.textTertiary,
                        fontSize: 11,
                        fontFamily: 'monospace',
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  itemCount: _entries.length,
                  itemBuilder: (context, index) {
                    final entry = _entries[index];
                    final isExpanded = _expandedIndex == index;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _expandedIndex = isExpanded ? null : index;
                        });
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 2),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: isExpanded ? c.surface : null,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                // Method badge
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 4, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: _methodBg(c, entry.method),
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                  child: Text(
                                    entry.method,
                                    style: TextStyle(
                                      color: _methodColor(c, entry.method),
                                      fontSize: 7,
                                      fontFamily: 'monospace',
                                      fontWeight: FontWeight.w700,
                                      decoration: TextDecoration.none,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                // Path
                                Expanded(
                                  child: Text(
                                    entry.path,
                                    style: TextStyle(
                                      color: c.textSecondary,
                                      fontSize: 9,
                                      fontFamily: 'monospace',
                                      decoration: TextDecoration.none,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                // Status
                                if (entry.statusCode != null &&
                                    entry.statusCode != 0)
                                  Text(
                                    '${entry.statusCode}',
                                    style: TextStyle(
                                      color: _statusColor(c, entry.statusCode),
                                      fontSize: 9,
                                      fontFamily: 'monospace',
                                      fontWeight: FontWeight.w700,
                                      decoration: TextDecoration.none,
                                    ),
                                  ),
                                const SizedBox(width: 6),
                                // Duration
                                Text(
                                  '${entry.durationMs}ms',
                                  style: TextStyle(
                                    color: c.textTertiary,
                                    fontSize: 8,
                                    fontFamily: 'monospace',
                                    decoration: TextDecoration.none,
                                  ),
                                ),
                                if (entry.isMock) ...[
                                  const SizedBox(width: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 4, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: c.purpleSoft,
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                    child: Text(
                                      'MOCK',
                                      style: TextStyle(
                                        color: c.purple,
                                        fontSize: 7,
                                        fontFamily: 'monospace',
                                        fontWeight: FontWeight.w700,
                                        decoration: TextDecoration.none,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            // Timestamp
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  _relativeTime(entry.timestamp),
                                  style: TextStyle(
                                    color: c.textTertiary,
                                    fontSize: 8,
                                    decoration: TextDecoration.none,
                                  ),
                                ),
                              ),
                            ),
                            // Expanded details
                            if (isExpanded) ...[
                              const SizedBox(height: 8),
                              Container(
                                height: 1,
                                color: c.border,
                              ),
                              const SizedBox(height: 8),
                              // Full URL
                              Text(
                                '${entry.method} ${entry.fullUrl}',
                                style: TextStyle(
                                  color: c.textSecondary,
                                  fontSize: 9,
                                  fontFamily: 'monospace',
                                  decoration: TextDecoration.none,
                                ),
                              ),
                              if (entry.requestHeaders.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Text(
                                  'Request headers',
                                  style: TextStyle(
                                    color: c.textTertiary,
                                    fontSize: 8,
                                    fontFamily: 'monospace',
                                    fontWeight: FontWeight.w600,
                                    decoration: TextDecoration.none,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                ...entry.requestHeaders.entries.map(
                                  (h) => Text(
                                    '  ${h.key}: ${h.value}',
                                    style: TextStyle(
                                      color: c.textTertiary,
                                      fontSize: 8,
                                      fontFamily: 'monospace',
                                      decoration: TextDecoration.none,
                                    ),
                                  ),
                                ),
                              ],
                              if (entry.requestBody != null) ...[
                                const SizedBox(height: 8),
                                Text(
                                  'Request body',
                                  style: TextStyle(
                                    color: c.textTertiary,
                                    fontSize: 8,
                                    fontFamily: 'monospace',
                                    fontWeight: FontWeight.w600,
                                    decoration: TextDecoration.none,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _prettyJson(entry.requestBody),
                                  style: TextStyle(
                                    color: c.textSecondary,
                                    fontSize: 8,
                                    fontFamily: 'monospace',
                                    decoration: TextDecoration.none,
                                  ),
                                  maxLines: 20,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                              if (entry.responseHeaders.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Text(
                                  'Response headers',
                                  style: TextStyle(
                                    color: c.textTertiary,
                                    fontSize: 8,
                                    fontFamily: 'monospace',
                                    fontWeight: FontWeight.w600,
                                    decoration: TextDecoration.none,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                ...entry.responseHeaders.entries.map(
                                  (h) => Text(
                                    '  ${h.key}: ${h.value}',
                                    style: TextStyle(
                                      color: c.textTertiary,
                                      fontSize: 8,
                                      fontFamily: 'monospace',
                                      decoration: TextDecoration.none,
                                    ),
                                  ),
                                ),
                              ],
                              if (entry.responseBody != null) ...[
                                const SizedBox(height: 8),
                                Text(
                                  'Response body',
                                  style: TextStyle(
                                    color: c.textTertiary,
                                    fontSize: 8,
                                    fontFamily: 'monospace',
                                    fontWeight: FontWeight.w600,
                                    decoration: TextDecoration.none,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                _buildResponseBody(c, entry.responseBody),
                              ],
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildResponseBody(HatchPanelColors c, dynamic body) {
    final text = _prettyJson(body);
    final truncated = text.length > 2000;
    final display = truncated ? text.substring(0, 2000) : text;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          display,
          style: TextStyle(
            color: c.textSecondary,
            fontSize: 8,
            fontFamily: 'monospace',
            decoration: TextDecoration.none,
          ),
          maxLines: 40,
          overflow: TextOverflow.ellipsis,
        ),
        if (truncated)
          Text(
            'show more',
            style: TextStyle(
              color: c.accent,
              fontSize: 8,
              fontFamily: 'monospace',
              decoration: TextDecoration.none,
            ),
          ),
      ],
    );
  }
}
