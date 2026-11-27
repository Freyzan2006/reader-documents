import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reader_documents/features/settings/data/app_settings.dart';
import 'package:reader_documents/features/settings/presentation/theme_settings_section.dart';

import '../helpers/test_app.dart';

void main() {
  for (final (label, mode) in const [
    ('Light', AppThemeMode.light),
    ('Dark', AppThemeMode.dark),
    ('System', AppThemeMode.system),
  ]) {
    testWidgets('tapping $label picks ${mode.name}', (tester) async {
      AppThemeMode? picked;
      await pumpTestApp(
        tester,
        SingleChildScrollView(
          child: ThemeSettingsSection(
            themeMode: mode == AppThemeMode.dark
                ? AppThemeMode.light
                : AppThemeMode.dark,
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
}
