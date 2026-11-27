import 'package:flutter_test/flutter_test.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';

import '../helpers/test_app.dart';

const splashDuration = Duration(milliseconds: 600);

void main() {
  testWidgets('renders home page with themed title', (tester) async {
    await pumpApplication(tester);
    await tester.pump();
    await tester.pump();
    await tester.pump(splashDuration);
    await tester.pump();

    expect(find.text('MDM'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Welcome'), findsOneWidget);
  });

  testWidgets('holds the launch screen long enough to be seen', (tester) async {
    await pumpApplication(tester);
    await tester.pump();
    await tester.pump();

    expect(
      find.byType(AppProgress),
      findsOneWidget,
      reason: 'launch screen should be up before the home page',
    );

    await tester.pump(splashDuration);
    await tester.pump();

    expect(find.byType(AppProgress), findsNothing);
  });
}
