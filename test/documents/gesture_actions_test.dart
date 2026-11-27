import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';
import 'package:reader_documents/features/documents/application/documents_providers.dart';
import 'package:reader_documents/features/documents/presentation/list/document_card.dart';
import 'package:reader_documents/features/documents/presentation/list/document_selection_aware_header.dart';
import 'package:reader_documents/features/documents/presentation/list/paginated_document_list.dart';

import '../helpers/fakes.dart';
import '../helpers/test_app.dart';

class _DocumentListScreen extends ConsumerWidget {
  const _DocumentListScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) => AppScaffold(
    header: const DocumentSelectionAwareHeader(
      normal: AppHeader(title: 'Documents'),
    ),
    child: Padding(
      padding: EdgeInsets.only(top: AppHeader.topInset(context)),
      child: PaginatedDocumentList(
        files: testDocuments,
        onOpen: (_) {},
        confirmDelete: (_) async => false,
        onDelete: (_) {},
      ),
    ),
  );
}

Future<void> _pumpList(
  WidgetTester tester, {
  FakeFavoritesRepository? favorites,
}) => pumpTestApp(
  tester,
  const _DocumentListScreen(),
  wrapApp: (app) => ProviderScope(
    overrides: [
      favoritesRepositoryProvider.overrideWithValue(
        favorites ?? FakeFavoritesRepository(),
      ),
    ],
    child: app,
  ),
);

void main() {
  testWidgetsWithSemantics(
    'long press selects a card and details opens its menu',
    (tester) async {
      await _pumpList(tester);
      await tester.pumpAndSettle();

      await tester.longPress(find.byType(DocumentCard).first);
      await tester.pumpAndSettle();

      expect(find.text('Document actions'), findsNothing);
      expect(find.text('1'), findsOneWidget);
      expect(find.bySemanticsLabel('Details'), findsOneWidget);

      await tester.tap(find.bySemanticsLabel('Details'));
      await tester.pumpAndSettle();

      expect(find.text('Document actions'), findsOneWidget);
      expect(find.text('Rename'), findsOneWidget);

      tester.state<NavigatorState>(find.byType(Navigator).first).pop();
      await tester.pumpAndSettle();

      await tester.tap(find.byType(DocumentCard).last);
      await tester.pumpAndSettle();

      expect(find.text('2'), findsOneWidget);
      expect(find.bySemanticsLabel('Details'), findsNothing);
    },
  );

  testWidgets('selection header fits a narrow phone', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await _pumpList(tester);
    await tester.pumpAndSettle();

    await tester.longPress(find.byType(DocumentCard).first);
    await tester.pumpAndSettle();

    expect(find.text('1'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('swiping a card right toggles favorite without deleting it', (
    tester,
  ) async {
    final favorites = FakeFavoritesRepository();
    await _pumpList(tester, favorites: favorites);
    await tester.pumpAndSettle();

    await tester.timedDragFrom(
      tester.getCenter(find.byType(DocumentCard).first),
      const Offset(300, 0),
      const Duration(milliseconds: 400),
    );
    await tester.pumpAndSettle();

    expect(favorites.values.keys, contains('/docs/a.pdf'));
    expect(find.byType(DocumentCard), findsNWidgets(2));
  });

  testWidgetsWithSemantics(
    'selection header favorites every selected document',
    (tester) async {
      final favorites = FakeFavoritesRepository();
      await _pumpList(tester, favorites: favorites);
      await tester.pumpAndSettle();

      await tester.longPress(find.byType(DocumentCard).first);
      await tester.pumpAndSettle();
      await tester.tap(find.bySemanticsLabel('Select all'));
      await tester.pumpAndSettle();

      expect(find.text('2'), findsOneWidget);

      await tester.tap(find.bySemanticsLabel('Add to favorites'));
      await tester.pumpAndSettle();

      expect(
        favorites.values.keys,
        containsAll(['/docs/a.pdf', '/docs/b.pdf']),
      );
      expect(find.text('Added 2 to favorites'), findsOneWidget);
    },
  );
}
