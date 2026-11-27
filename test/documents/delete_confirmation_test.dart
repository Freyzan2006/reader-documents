import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reader_documents/features/documents/presentation/actions/document_commands.dart';

import '../helpers/fakes.dart';
import '../helpers/test_app.dart';

class _ConfirmProbe extends StatelessWidget {
  const _ConfirmProbe({required this.onResult});

  final ValueChanged<bool> onResult;

  @override
  Widget build(BuildContext context) => Center(
    child: GestureDetector(
      onTap: () async => onResult(
        await DocumentCommands.confirmDelete(context, testDocuments.first),
      ),
      child: const Text('Ask'),
    ),
  );
}

Future<bool?> _answer(WidgetTester tester, String button) async {
  bool? result;
  await pumpTestApp(tester, _ConfirmProbe(onResult: (value) => result = value));

  await tester.tap(find.text('Ask'));
  await tester.pumpAndSettle();

  expect(find.text('Delete document?'), findsOneWidget);

  await tester.tap(find.text(button));
  await tester.pumpAndSettle();

  expect(find.text('Delete document?'), findsNothing);
  return result;
}

void main() {
  testWidgets('cancelling the delete dialog keeps the document', (
    tester,
  ) async {
    expect(await _answer(tester, 'Cancel'), isFalse);
  });

  testWidgets('confirming the delete dialog deletes the document', (
    tester,
  ) async {
    expect(await _answer(tester, 'Delete'), isTrue);
  });
}
