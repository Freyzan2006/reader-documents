import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reader_documents/core/storage/app_cache.dart';
import 'package:reader_documents/features/settings/application/cache_commands.dart';
import 'package:reader_documents/features/settings/application/settings_providers.dart';
import 'package:reader_documents/features/settings/presentation/about_screen.dart';
import 'package:reader_documents/features/settings/presentation/settings_screen.dart';

import '../helpers/test_app.dart';

class _EmptyCache implements AppCache {
  @override
  Future<int> size() async => 0;

  @override
  Future<int> clear() async => 0;
}

void main() {
  testWidgets('about opens from settings and lists what the app stands for', (
    tester,
  ) async {
    await pumpTestApp(
      tester,
      ProviderScope(
        overrides: [
          settingsProvider.overrideWith(TestSettingsNotifier.new),
          appCacheProvider.overrideWithValue(_EmptyCache()),
        ],
        child: const SettingsScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('No ads'), findsNothing);

    await tester.ensureVisible(find.text('About'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('About'));
    await tester.pumpAndSettle();

    expect(find.byType(AboutScreen), findsOneWidget);
    for (final title in const [
      'No ads',
      'Privacy',
      'Completely free',
      'All formats in one app',
    ]) {
      expect(find.text(title), findsOneWidget);
    }
    expect(
      find.text('Your files are stored only on your device.'),
      findsOneWidget,
    );
  });
}
