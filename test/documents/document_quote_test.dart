import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reader_documents/features/documents/data/models/document_highlight.dart';
import 'package:reader_documents/features/documents/presentation/actions/document_quote.dart';
import 'package:reader_documents/l10n/app_localizations.dart';

void main() {
  Future<AppLocalizations> l10n(String code) =>
      AppLocalizations.delegate.load(Locale(code));

  test('russian quote uses guillemets and the page', () async {
    expect(
      DocumentQuote.format(
        l10n: await l10n('ru'),
        text: '  Текст ',
        title: 'Книга',
        pageNumber: 12,
      ),
      '«Текст»\n— Книга, стр. 12',
    );
  });

  test('english quote uses curly quotes', () async {
    expect(
      DocumentQuote.format(
        l10n: await l10n('en'),
        text: 'Text',
        title: 'Book',
        pageNumber: 3,
      ),
      '“Text”\n— Book, p. 3',
    );
  });

  test('without a page only the title is cited', () async {
    expect(
      DocumentQuote.format(l10n: await l10n('ru'), text: 'Т', title: 'Книга'),
      '«Т»\n— Книга',
    );
  });

  test('highlights saved before notes load with an empty note', () {
    final highlight = DocumentHighlight.fromJson({
      'id': '1',
      'pageNumber': 1,
      'startIndex': 0,
      'endIndex': 1,
      'rects': <Object>[],
      'color': 'yellow',
      'text': 'T',
      'createdAt': '2026-01-01T00:00:00.000',
    });
    expect(highlight.note, '');
    expect(highlight.toJson().containsKey('note'), isFalse);

    final noted = highlight.copyWith(note: 'N');
    expect(DocumentHighlight.fromJson(noted.toJson()).note, 'N');
  });
}
