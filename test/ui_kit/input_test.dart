import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';

import '../helpers/test_app.dart';

Future<void> _pump(WidgetTester tester, Widget child) => pumpTestApp(
  tester,
  Center(
    child: Padding(padding: const EdgeInsets.all(24), child: child),
  ),
);

void main() {
  testWidgets('input reports typing and submit, and hides the hint', (
    tester,
  ) async {
    final changes = <String>[];
    String? submitted;
    await _pump(
      tester,
      AppInput(
        label: 'Document name',
        hint: 'Untitled',
        onChanged: changes.add,
        onSubmitted: (value) => submitted = value,
      ),
    );

    expect(find.text('Untitled'), findsOneWidget);

    await tester.enterText(find.byType(EditableText), 'Annual report');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(changes.last, 'Annual report');
    expect(submitted, 'Annual report');
    expect(find.text('Untitled'), findsNothing);
    expect(find.text('Document name'), findsOneWidget);
  });

  testWidgets('input shows its error instead of the help line', (tester) async {
    await _pump(
      tester,
      const AppInput(
        hint: 'Password',
        obscureText: true,
        help: 'Ask the sender',
        error: 'Wrong password. Try again.',
      ),
    );

    expect(find.text('Wrong password. Try again.'), findsOneWidget);
    expect(find.text('Ask the sender'), findsNothing);
    expect(
      tester.widget<EditableText>(find.byType(EditableText)).obscureText,
      isTrue,
    );
  });

  testWidgets('number input clamps typed values and steps with buttons', (
    tester,
  ) async {
    final controller = TextEditingController(text: '5');
    addTearDown(controller.dispose);
    final values = <int?>[];
    int? submitted;
    await _pump(
      tester,
      AppNumberInput(
        controller: controller,
        min: 1,
        max: 10,
        onChanged: values.add,
        onSubmitted: (value) => submitted = value,
      ),
    );

    await tester.tap(find.byIcon(AppIcons.plus));
    await tester.pumpAndSettle();
    expect(controller.text, '6');

    await tester.enterText(find.byType(EditableText), '42');
    await tester.testTextInput.receiveAction(TextInputAction.go);
    await tester.pumpAndSettle();

    expect(controller.text, '10');
    expect(submitted, 10);
    expect(values, contains(6));
  });

  testWidgets('search field clears its query', (tester) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    String? last;
    await _pump(
      tester,
      AppSearchField(
        controller: controller,
        hint: 'Search by name…',
        clearLabel: 'Clear',
        onChanged: (value) => last = value,
      ),
    );

    await tester.enterText(find.byType(EditableText), 'report');
    await tester.pumpAndSettle();
    expect(find.byIcon(AppIcons.x), findsOneWidget);

    await tester.tap(find.byIcon(AppIcons.x));
    await tester.pumpAndSettle();

    expect(controller.text, isEmpty);
    expect(last, '');
    expect(find.text('Search by name…'), findsOneWidget);
  });

  testWidgets('long press selects a word and offers copy', (tester) async {
    final controller = TextEditingController(text: 'annual report');
    addTearDown(controller.dispose);
    await _pump(tester, AppInput(controller: controller));

    final field = tester.getRect(find.byType(EditableText));
    await tester.longPressAt(Offset(field.left + 20, field.center.dy));
    await tester.pumpAndSettle();

    expect(controller.selection.isCollapsed, isFalse);
    expect(find.byType(AppTextContextMenu), findsOneWidget);
    expect(find.text('Copy'), findsOneWidget);
  });
}
