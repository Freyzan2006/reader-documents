import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reader_documents/core/ui_kit/tokens/app_palette.dart';
import 'package:reader_documents/features/settings/presentation/palette_settings_section.dart';

import '../helpers/test_app.dart';

void main() {
  for (final (label, family) in const [
    ('Monochrome', AppPaletteFamily.monochrome),
    ('Ink', AppPaletteFamily.ink),
  ]) {
    testWidgets('tapping $label picks ${family.name}', (tester) async {
      AppPaletteFamily? picked;
      await pumpTestApp(
        tester,
        SingleChildScrollView(
          child: PaletteSettingsSection(
            palette: family == AppPaletteFamily.ink
                ? AppPaletteFamily.monochrome
                : AppPaletteFamily.ink,
            onChanged: (value) => picked = value,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text(label));
      await tester.pumpAndSettle();

      expect(picked, family);
    });
  }
}
