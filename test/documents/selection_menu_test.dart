import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reader_documents/features/documents/application/controllers/document_highlights_controller.dart';
import 'package:reader_documents/features/documents/application/providers/selection_tools.dart';
import 'package:reader_documents/features/documents/data/models/document_highlight.dart';
import 'package:reader_documents/features/documents/data/repositories/highlights_repository.dart';
import 'package:reader_documents/features/documents/presentation/viewer/common/document_context_menu.dart';
import 'package:reader_documents/features/documents/presentation/viewer/common/document_context_menu_content.dart';
import 'package:reader_documents/features/documents/presentation/viewer/contract/document_text_selection.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/test_app.dart';

const _draft = DocumentHighlightDraft(
  pageNumber: 1,
  startIndex: 0,
  endIndex: 5,
  text: 'Hello',
  rects: [],
);

class _Selection implements DocumentTextSelection {
  _Selection({this.hasSelectedText = true, this.isCopyAllowed = true});

  @override
  final bool hasSelectedText;

  @override
  final bool isCopyAllowed;

  int selectAllCalls = 0;
  int copyCalls = 0;

  @override
  bool get isSelectingAllText => false;

  @override
  Future<String> getSelectedText() async => 'Hello';

  @override
  void copyTextSelection() => copyCalls++;

  @override
  void selectAllText() => selectAllCalls++;

  @override
  DocumentHighlightDraft? get highlightDraft => hasSelectedText ? _draft : null;
}

Finder _button(String semanticsLabel) => find.byWidgetPredicate(
  (widget) =>
      widget is DocumentContextMenuButton &&
      (widget.semanticsLabel ?? widget.label) == semanticsLabel,
);

void main() {
  late DocumentHighlightsController highlights;
  late int dismissed;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    highlights = DocumentHighlightsController(
      const HighlightsRepository(),
      '/docs/a.pdf',
    );
    dismissed = 0;
  });

  Future<void> pump(WidgetTester tester, DocumentTextSelection selection) =>
      pumpTestApp(
        tester,
        ProviderScope(
          child: Center(
            child: DocumentContextMenuContent(
              selection: selection,
              highlights: highlights,
              dismiss: () => dismissed++,
              documentTitle: 'Book',
            ),
          ),
        ),
      );

  testWidgets('shows colors, copy and labelled external actions', (
    tester,
  ) async {
    await pump(tester, _Selection());
    await tester.pumpAndSettle();

    for (final label in const [
      'Highlight yellow',
      'Highlight green',
      'Highlight pink',
      'Note',
      'Copy',
      'Translate: opens Google Translate',
      'AI: opens ChatGPT',
      'Search: opens Google',
      'More',
    ]) {
      expect(_button(label), findsOneWidget, reason: label);
    }
    expect(find.text('Translate'), findsOneWidget);
    expect(_button('Select All'), findsNothing);
  });

  testWidgets('one tap highlights and remembers the color', (tester) async {
    await pump(tester, _Selection());
    await tester.pumpAndSettle();

    await tester.tap(_button('Highlight green'));
    await tester.pumpAndSettle();

    expect(highlights.value.single.color, DocumentHighlightColor.green);
    expect(dismissed, 1);
    final saved = await const SelectionToolsRepository().load();
    expect(saved?.highlightColor, DocumentHighlightColor.green);
    expect(find.text('Highlight added'), findsOneWidget);

    await tester.tap(find.text('UNDO'));
    await tester.pumpAndSettle();
    expect(highlights.value, isEmpty);
  });

  testWidgets('copy copies the text and confirms it', (tester) async {
    final selection = _Selection();
    await pump(tester, selection);
    await tester.pumpAndSettle();

    await tester.tap(_button('Copy'));
    await tester.pumpAndSettle();

    expect(selection.copyCalls, 1);
    expect(dismissed, 1);
    expect(find.text('Copied to clipboard'), findsOneWidget);
  });

  testWidgets('the last used color comes first', (tester) async {
    await const SelectionToolsRepository().save(
      const SelectionTools(highlightColor: DocumentHighlightColor.pink),
    );
    await pump(tester, _Selection());
    await tester.pumpAndSettle();

    final pink = tester.getTopLeft(_button('Highlight pink')).dx;
    final yellow = tester.getTopLeft(_button('Highlight yellow')).dx;
    expect(pink, lessThan(yellow));
  });

  testWidgets('an existing highlight can be recolored or removed', (
    tester,
  ) async {
    await highlights.add(_draft, DocumentHighlightColor.yellow);
    await pump(tester, _Selection());
    await tester.pumpAndSettle();

    await tester.tap(_button('Highlight pink'));
    await tester.pumpAndSettle();
    expect(highlights.value.single.color, DocumentHighlightColor.pink);

    await tester.tap(_button('Remove Highlight'));
    await tester.pumpAndSettle();
    expect(highlights.value, isEmpty);
  });

  testWidgets('without selected text only select all is offered', (
    tester,
  ) async {
    final selection = _Selection(hasSelectedText: false);
    await pump(tester, selection);
    await tester.pumpAndSettle();

    expect(find.byType(DocumentContextMenuButton), findsOneWidget);
    await tester.tap(_button('Select All'));
    expect(selection.selectAllCalls, 1);
  });

  testWidgets('more opens a sheet with the text and every service', (
    tester,
  ) async {
    final selection = _Selection();
    await pump(tester, selection);
    await tester.pumpAndSettle();

    await tester.tap(_button('More'));
    await tester.pumpAndSettle();

    expect(dismissed, 1);
    expect(find.text('Text actions'), findsOneWidget);
    expect(find.text('Hello'), findsOneWidget);
    for (final service in const [
      'Google Translate',
      'Yandex Translate',
      'ChatGPT',
      'Claude',
      'Wikipedia',
    ]) {
      expect(find.text(service), findsOneWidget, reason: service);
    }

    await tester.tap(find.text('Select All'));
    await tester.pumpAndSettle();
    expect(selection.selectAllCalls, 1);
  });

  testWidgets('note saves the highlight with its note', (tester) async {
    await pump(tester, _Selection());
    await tester.pumpAndSettle();

    await tester.tap(_button('Note'));
    await tester.pumpAndSettle();
    expect(find.text('Highlight note'), findsOneWidget);

    await tester.enterText(find.byType(EditableText), 'Key idea');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(highlights.value.single.note, 'Key idea');
    expect(find.text('Note saved'), findsOneWidget);
  });

  testWidgets('note on an existing highlight edits it', (tester) async {
    final existing = await highlights.add(
      _draft,
      DocumentHighlightColor.green,
      note: 'Old',
    );
    await pump(tester, _Selection());
    await tester.pumpAndSettle();

    await tester.tap(_button('Edit note'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(EditableText), 'New');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(highlights.value.single.id, existing.id);
    expect(highlights.value.single.note, 'New');
    expect(highlights.value.single.color, DocumentHighlightColor.green);
  });

  testWidgets('copy as quote adds the source and the page', (tester) async {
    String? copied;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          copied = (call.arguments as Map)['text'] as String;
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );

    await pump(tester, _Selection());
    await tester.pumpAndSettle();
    await tester.tap(_button('More'));
    await tester.pumpAndSettle();

    expect(find.text('Share'), findsOneWidget);
    await tester.tap(find.text('Copy as quote'));
    await tester.pumpAndSettle();

    expect(copied, '\u201CHello\u201D\n\u2014 Book, p. 1');
    expect(find.text('Copied to clipboard'), findsOneWidget);
  });

  testWidgets('quote and share are hidden when copying is forbidden', (
    tester,
  ) async {
    await pump(tester, _Selection(isCopyAllowed: false));
    await tester.pumpAndSettle();
    expect(_button('Copy'), findsNothing);

    await tester.tap(_button('More'));
    await tester.pumpAndSettle();

    expect(find.text('Share'), findsNothing);
    expect(find.text('Copy as quote'), findsNothing);
  });
}
