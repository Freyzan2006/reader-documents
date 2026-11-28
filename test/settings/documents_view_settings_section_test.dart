import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reader_documents/core/ui_kit/tokens/app_breakpoints.dart';
import 'package:reader_documents/features/settings/data/app_settings.dart';
import 'package:reader_documents/features/settings/presentation/documents_view_settings_section.dart';

import '../helpers/test_app.dart';

void main() {
  group('DocumentsLayout.useCardRow', () {
    test('auto follows the screen size', () {
      expect(DocumentsLayout.auto.useCardRow(ScreenSize.mobile), isFalse);
      expect(DocumentsLayout.auto.useCardRow(ScreenSize.tablet), isTrue);
      expect(DocumentsLayout.auto.useCardRow(ScreenSize.desktop), isTrue);
    });

    test('card and cardrow ignore the screen size', () {
      for (final size in ScreenSize.values) {
        expect(DocumentsLayout.card.useCardRow(size), isFalse);
        expect(DocumentsLayout.cardrow.useCardRow(size), isTrue);
      }
    });
  });

  testWidgets('preview cards fit a narrow phone', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await pumpTestApp(
      tester,
      SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: DocumentsViewSettingsSection(
            layout: DocumentsLayout.auto,
            onChanged: (_) {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('now: card'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final (label, layout) in const [
    ('Auto', DocumentsLayout.auto),
    ('Card', DocumentsLayout.card),
    ('Card row', DocumentsLayout.cardrow),
  ]) {
    testWidgets('tapping $label picks ${layout.name}', (tester) async {
      DocumentsLayout? picked;
      await pumpTestApp(
        tester,
        SingleChildScrollView(
          child: DocumentsViewSettingsSection(
            layout: layout == DocumentsLayout.card
                ? DocumentsLayout.cardrow
                : DocumentsLayout.card,
            onChanged: (value) => picked = value,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text(label));
      await tester.pumpAndSettle();

      expect(picked, layout);
    });
  }
}
