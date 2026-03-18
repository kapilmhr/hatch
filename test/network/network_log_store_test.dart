import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:hatch/src/network/network_log_store.dart';

void main() {
  group('NetworkLogStore', () {
    late NetworkLogStore store;

    NetworkLogEntry makeEntry({String method = 'GET', String path = '/test'}) {
      return NetworkLogEntry(
        method: method,
        fullUrl: 'https://api.com$path',
        path: path,
        statusCode: 200,
        durationMs: 100,
        timestamp: DateTime.now(),
      );
    }

    setUp(() {
      store = NetworkLogStore(maxEntries: 3);
    });

    test('stores entries up to maxNetworkLogEntries', () {
      store.add(makeEntry(path: '/1'));
      store.add(makeEntry(path: '/2'));
      store.add(makeEntry(path: '/3'));

      expect(store.length, 3);
    });

    test('drops oldest entry when buffer is full', () {
      store.add(makeEntry(path: '/1'));
      store.add(makeEntry(path: '/2'));
      store.add(makeEntry(path: '/3'));
      store.add(makeEntry(path: '/4'));

      expect(store.length, 3);
      // Newest first in the entries list
      final entries = store.entries;
      expect(entries[0].path, '/4');
      expect(entries[1].path, '/3');
      expect(entries[2].path, '/2');
    });

    test('clear() empties the buffer', () {
      store.add(makeEntry());
      store.add(makeEntry());
      store.clear();

      expect(store.length, 0);
      expect(store.entries, isEmpty);
    });

    test('stream emits on each new entry', () async {
      final completer = Completer<List<NetworkLogEntry>>();
      store.stream.first.then(completer.complete);

      store.add(makeEntry(path: '/stream_test'));

      final entries = await completer.future;
      expect(entries.length, 1);
      expect(entries[0].path, '/stream_test');
    });

    test('stream emits on clear', () async {
      store.add(makeEntry());

      final completer = Completer<List<NetworkLogEntry>>();
      store.stream.first.then(completer.complete);

      store.clear();

      final entries = await completer.future;
      expect(entries, isEmpty);
    });
  });
}
