import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';
import 'package:reader_documents/features/documents/application/providers/gesture_hint.dart';
import 'package:reader_documents/features/documents/presentation/list/document_gesture_hint_banner.dart';
import 'package:reader_documents/features/settings/application/settings_providers.dart';
import 'package:reader_documents/features/settings/presentation/settings_screen.dart';

import '../helpers/fakes.dart';
import '../helpers/test_app.dart';

void main() {
  testWidgets('reset hints button clears seen gesture hint', (tester) async {
    final hint = FakeGestureHintRepository(true);

    await pumpTestApp(
      tester,
      ProviderScope(
        overrides: [
          settingsProvider.overrideWith(TestSettingsNotifier.new),
          gestureHintRepositoryProvider.overrideWithValue(hint),
        ],
        child: const SettingsScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Reset hints'), findsOneWidget);

    await tester.tap(find.text('Reset hints'));
    await tester.pumpAndSettle();

    expect(hint.seen, isFalse);
    expect(find.text('Hints will be shown again'), findsOneWidget);
  });

  testWidgets('reset hint re-enables gesture banner after it was dismissed', (
    tester,
  ) async {
    final hint = FakeGestureHintRepository(false);

    Widget app() => ProviderScope(
      overrides: [gestureHintRepositoryProvider.overrideWithValue(hint)],
      child: const DocumentGestureHintBanner(),
    );

    await pumpTestApp(tester, app());
    await tester.pumpAndSettle();
    expect(find.text('Press and hold a card for actions'), findsOneWidget);

    await tester.tap(find.byIcon(AppIcons.x));
    await tester.pumpAndSettle();
    expect(hint.seen, isTrue);
    expect(find.text('Press and hold a card for actions'), findsNothing);

    await tester.container().read(gestureHintSeenProvider.notifier).reset();
    await tester.pumpAndSettle();

    expect(find.text('Press and hold a card for actions'), findsOneWidget);
  });
}
