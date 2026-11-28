import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';
import 'package:reader_documents/features/settings/data/app_settings.dart';
import 'package:reader_documents/features/settings/presentation/document_previews_settings_section.dart';

import '../helpers/test_app.dart';

void main() {
  for (final (label, previews) in const [
    ('Auto', DocumentPreviews.auto),
    ('Show', DocumentPreviews.show),
    ('Hide', DocumentPreviews.hide),
  ]) {
    testWidgets('tapping $label picks ${previews.name}', (tester) async {
      DocumentPreviews? picked;
      await pumpTestApp(
        tester,
        SingleChildScrollView(
          child: DocumentPreviewsSettingsSection(
            previews: previews == DocumentPreviews.show
                ? DocumentPreviews.hide
                : DocumentPreviews.show,
            onChanged: (value) => picked = value,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text(label));
      await tester.pumpAndSettle();

      expect(picked, previews);
    });
  }

  for (final (graphics, now) in const [
    (GraphicsMode.quality, 'now: on'),
    (GraphicsMode.performance, 'now: off'),
  ]) {
    testWidgets('auto shows "$now" in ${graphics.name} on a narrow phone', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await pumpTestApp(
        tester,
        graphics: graphics,
        SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: DocumentPreviewsSettingsSection(
              previews: DocumentPreviews.auto,
              onChanged: (_) {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(now), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
