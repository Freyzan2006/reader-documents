import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reader_documents/features/documents/application/documents_providers.dart';
import 'package:reader_documents/features/documents/presentation/list/document_card.dart';

import '../helpers/fakes.dart';
import '../helpers/test_app.dart';

Future<void> _pumpCard(
  WidgetTester tester, {
  required FakePageCountRepository pageCounts,
  bool tile = false,
}) => pumpTestApp(
  tester,
  ProviderScope(
    overrides: [pageCountRepositoryProvider.overrideWithValue(pageCounts)],
    child: tile
        ? Center(
            child: SizedBox(
              width: 160,
              height: 280,
              child: DocumentCard(file: testDocuments.first, tile: true),
            ),
          )
        : DocumentCard(file: testDocuments.first),
  ),
);

void main() {
  testWidgets('card shows the saved page count next to the file size', (
    tester,
  ) async {
    await _pumpCard(
      tester,
      pageCounts: FakePageCountRepository({testDocuments.first.path: 12}),
    );
    await tester.pumpAndSettle();

    expect(find.text('1.0 KB · 12 pp'), findsOneWidget);
  });

  testWidgets('compact card shows the saved page count too', (tester) async {
    await _pumpCard(
      tester,
      pageCounts: FakePageCountRepository({testDocuments.first.path: 7}),
      tile: true,
    );
    await tester.pumpAndSettle();

    expect(find.text('1.0 KB · 7 pp'), findsOneWidget);
  });

  testWidgets('card omits the page count when it is unknown', (tester) async {
    await _pumpCard(tester, pageCounts: FakePageCountRepository({}));
    await tester.pumpAndSettle();

    expect(find.text('1.0 KB'), findsOneWidget);
    expect(find.textContaining(' pp'), findsNothing);
  });
}
