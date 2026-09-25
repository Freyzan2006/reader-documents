import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reader_documents/main.dart';

void main() {
  testWidgets('renders home page with themed title', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: ReaderDocumentsApp()));
    await tester.pump();

    expect(find.text('RD'), findsOneWidget);
    expect(find.text('Documents'), findsOneWidget);
  });
}
