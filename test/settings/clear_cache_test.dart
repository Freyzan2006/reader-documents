import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reader_documents/core/storage/app_cache.dart';
import 'package:reader_documents/features/settings/application/cache_commands.dart';
import 'package:reader_documents/features/settings/application/settings_providers.dart';
import 'package:reader_documents/features/settings/presentation/settings_screen.dart';

import '../helpers/test_app.dart';

class _FakeCache implements AppCache {
  _FakeCache(this.bytes);

  int bytes;

  @override
  Future<int> size() async => bytes;

  @override
  Future<int> clear() async {
    final freed = bytes;
    bytes = 0;
    return freed;
  }
}

Future<void> _pump(WidgetTester tester, AppCache cache) => pumpTestApp(
  tester,
  ProviderScope(
    overrides: [
      settingsProvider.overrideWith(TestSettingsNotifier.new),
      appCacheProvider.overrideWithValue(cache),
    ],
    child: const SettingsScreen(),
  ),
);

void main() {
  testWidgets('clear cache shows the size, empties the cache and reports it', (
    tester,
  ) async {
    final cache = _FakeCache(2048);
    await _pump(tester, cache);
    await tester.pumpAndSettle();

    expect(find.text('Clear cache'), findsOneWidget);
    expect(find.textContaining('2.0 KB'), findsOneWidget);

    await tester.tap(find.text('Clear'));
    await tester.pumpAndSettle();

    expect(cache.bytes, 0);
    expect(find.text('Cache cleared · 2.0 KB freed'), findsOneWidget);
    expect(find.textContaining('0 B'), findsOneWidget);
  });

  testWidgets('clearing an empty cache says so', (tester) async {
    await _pump(tester, _FakeCache(0));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Clear cache'));
    await tester.pumpAndSettle();

    expect(find.text('Cache is already empty'), findsOneWidget);
  });
}
