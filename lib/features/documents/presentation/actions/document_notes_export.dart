import 'package:reader_documents/features/documents/data/models/document_bookmark.dart';
import 'package:reader_documents/features/documents/data/models/document_highlight.dart';
import 'package:reader_documents/l10n/app_localizations.dart';
import 'package:share_plus/share_plus.dart';

abstract final class DocumentNotesExport {
  static bool hasContent(
    List<DocumentBookmark> bookmarks,
    List<DocumentHighlight> highlights,
  ) => bookmarks.isNotEmpty || highlights.isNotEmpty;

  static Future<void> export({
    required AppLocalizations l10n,
    required String documentTitle,
    required List<DocumentBookmark> bookmarks,
    required List<DocumentHighlight> highlights,
  }) => SharePlus.instance.share(
    ShareParams(
      subject: documentTitle,
      text: _digest(l10n, documentTitle, bookmarks, highlights),
    ),
  );

  static String _digest(
    AppLocalizations l10n,
    String documentTitle,
    List<DocumentBookmark> bookmarks,
    List<DocumentHighlight> highlights,
  ) {
    final sortedBookmarks = [...bookmarks]
      ..sort((a, b) => a.pageNumber.compareTo(b.pageNumber));
    final sortedHighlights = [...highlights]
      ..sort((a, b) => a.pageNumber.compareTo(b.pageNumber));

    final buffer = StringBuffer()..writeln(documentTitle);

    if (sortedBookmarks.isNotEmpty) {
      buffer
        ..writeln()
        ..writeln(l10n.pdfMenuBookmarks);
      for (final bookmark in sortedBookmarks) {
        final page = l10n.bookmarkPageLabel(bookmark.pageNumber);
        buffer.writeln(
          bookmark.note.isEmpty ? '• $page' : '• $page: ${bookmark.note}',
        );
      }
    }

    if (sortedHighlights.isNotEmpty) {
      buffer
        ..writeln()
        ..writeln(l10n.exportNotesHighlightsSection);
      for (final highlight in sortedHighlights) {
        final page = l10n.bookmarkPageLabel(highlight.pageNumber);
        buffer.writeln('• $page: "${highlight.text}"');
      }
    }

    return buffer.toString().trim();
  }
}
