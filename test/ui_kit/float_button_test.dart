import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';

import '../helpers/test_app.dart';

void main() {
  for (final graphics in GraphicsMode.values) {
    testWidgets('float button collapses its label in $graphics', (
      tester,
    ) async {
      final extended = ValueNotifier(true);
      await pumpTestApp(
        tester,
        Center(
          child: ValueListenableBuilder(
            valueListenable: extended,
            builder: (_, value, _) => AppFloatButton(
              icon: AppIcons.fileText,
              label: 'Add',
              extended: value,
              onPressed: () {},
            ),
          ),
        ),
        graphics: graphics,
      );

      extended.value = false;
      await tester.pumpAndSettle();
      extended.value = true;
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Add'), findsOneWidget);
    });
  }
}
