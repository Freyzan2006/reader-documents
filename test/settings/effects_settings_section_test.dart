import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reader_documents/features/settings/data/app_settings.dart';
import 'package:reader_documents/features/settings/presentation/effects_settings_section.dart';

import '../helpers/test_app.dart';

void main() {
  for (final (label, mode) in const [
    ('Auto', AppEffectsMode.system),
    ('Quality', AppEffectsMode.quality),
    ('Performance', AppEffectsMode.performance),
  ]) {
    testWidgets('tapping $label picks ${mode.name}', (tester) async {
      AppEffectsMode? picked;
      await pumpTestApp(
        tester,
        SingleChildScrollView(
          child: EffectsSettingsSection(
            effectsMode: mode == AppEffectsMode.quality
                ? AppEffectsMode.performance
                : AppEffectsMode.quality,
            onChanged: (value) => picked = value,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text(label));
      await tester.pumpAndSettle();

      expect(picked, mode);
    });
  }

  testWidgets('preview cards fit a narrow phone', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await pumpTestApp(
      tester,
      SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: EffectsSettingsSection(
            effectsMode: AppEffectsMode.system,
            onChanged: (_) {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('now: quality'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
