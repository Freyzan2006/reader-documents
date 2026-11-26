import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';
import 'package:reader_documents/features/documents/application/documents_providers.dart';
import 'package:reader_documents/features/documents/data/models/document_file.dart';
import 'package:reader_documents/features/documents/data/repositories/favorites_repository.dart';
import 'package:reader_documents/features/documents/presentation/list/document_card.dart';
import 'package:reader_documents/features/documents/presentation/list/document_selection_aware_header.dart';
import 'package:reader_documents/features/documents/presentation/list/paginated_document_list.dart';
import 'package:reader_documents/l10n/app_localizations.dart';

class _FakeFavoritesRepository extends FavoritesRepository {
  final Map<String, bool> values = {};

  @override
  Future<Map<String, bool>> loadAll() async => Map.of(values);

  @override
  Future<void> save(String documentPath, bool value) async =>
      values[documentPath] = value;

  @override
  Future<void> clear(String documentPath) async => values.remove(documentPath);
}

final _files = [
  DocumentFile(
    path: '/docs/a.pdf',
    name: 'a.pdf',
    type: DocumentType.pdf,
    sizeBytes: 1024,
    modifiedAt: DateTime(2026),
  ),
  DocumentFile(
    path: '/docs/b.pdf',
    name: 'b.pdf',
    type: DocumentType.pdf,
    sizeBytes: 2048,
    modifiedAt: DateTime(2026),
  ),
];

class _TestList extends ConsumerWidget {
  const _TestList();

  @override
  Widget build(BuildContext context, WidgetRef ref) => AppScaffold(
    header: const DocumentSelectionAwareHeader(
      normal: AppHeader(title: 'Documents'),
    ),
    child: Padding(
      padding: EdgeInsets.only(top: AppHeader.topInset(context)),
      child: PaginatedDocumentList(
        files: _files,
        onOpen: (_) {},
        confirmDelete: (_) async => false,
        onDelete: (_) {},
      ),
    ),
  );
}

Widget _app(_FakeFavoritesRepository favorites) => ProviderScope(
  overrides: [favoritesRepositoryProvider.overrideWithValue(favorites)],
  child: MaterialApp(
    localizationsDelegates: [
      ...AppLocalizations.localizationsDelegates,
      ...FLocalizations.localizationsDelegates,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    home: FTheme(
      data: AppTheme.of(Brightness.light),
      child: FToaster(child: const _TestList()),
    ),
  ),
);

void main() {
  testWidgets('long press selects a card and details opens its menu', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(_app(_FakeFavoritesRepository()));
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
    semantics.dispose();
  });

  testWidgets('selection header fits a narrow phone', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_app(_FakeFavoritesRepository()));
    await tester.pumpAndSettle();

    await tester.longPress(find.byType(DocumentCard).first);
    await tester.pumpAndSettle();

    expect(find.text('1'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('swiping a card right toggles favorite without deleting it', (
    tester,
  ) async {
    final favorites = _FakeFavoritesRepository();
    await tester.pumpWidget(_app(favorites));
    await tester.pumpAndSettle();

    final card = find.byType(DocumentCard).first;
    await tester.timedDragFrom(
      tester.getCenter(card),
      const Offset(300, 0),
      const Duration(milliseconds: 400),
    );
    await tester.pumpAndSettle();

    expect(favorites.values.keys, contains('/docs/a.pdf'));
    expect(find.byType(DocumentCard), findsNWidgets(2));
  });

  testWidgets('selection header favorites every selected document', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    final favorites = _FakeFavoritesRepository();
    await tester.pumpWidget(_app(favorites));
    await tester.pumpAndSettle();

    await tester.longPress(find.byType(DocumentCard).first);
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('Select all'));
    await tester.pumpAndSettle();

    expect(find.text('2'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Add to favorites'));
    await tester.pumpAndSettle();

    expect(favorites.values.keys, containsAll(['/docs/a.pdf', '/docs/b.pdf']));
    expect(find.text('Added 2 to favorites'), findsOneWidget);
    semantics.dispose();
  });
}
