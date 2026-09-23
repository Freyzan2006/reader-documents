import 'package:flutter_test/flutter_test.dart';

import 'package:reader_documents/main.dart';

void main() {
  testWidgets('renders home page with themed title', (WidgetTester tester) async {
    await tester.pumpWidget(const ReaderDocumentsApp());

    expect(find.text('Reader Documents'), findsOneWidget);
    expect(find.text('Themed with Forui'), findsOneWidget);
  });
}
