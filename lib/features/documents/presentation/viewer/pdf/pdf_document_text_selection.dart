import 'dart:math' as math;

import 'package:pdfrx/pdfrx.dart';
import 'package:reader_documents/features/documents/data/models/document_highlight.dart';
import 'package:reader_documents/features/documents/presentation/viewer/contract/document_text_selection.dart';

import 'pdf_rect_mapping.dart';

class PdfDocumentTextSelection implements DocumentTextSelection {
  const PdfDocumentTextSelection(this._params);

  final PdfViewerContextMenuBuilderParams _params;

  @override
  bool get isCopyAllowed => _params.textSelectionDelegate.isCopyAllowed;

  @override
  bool get hasSelectedText => _params.textSelectionDelegate.hasSelectedText;

  @override
  bool get isSelectingAllText =>
      _params.textSelectionDelegate.isSelectingAllText;

  @override
  Future<String> getSelectedText() =>
      _params.textSelectionDelegate.getSelectedText();

  @override
  void copyTextSelection() => _params.textSelectionDelegate.copyTextSelection();

  @override
  void selectAllText() => _params.textSelectionDelegate.selectAllText();

  @override
  DocumentHighlightDraft? get highlightDraft {
    final anchorA = _params.a;
    final anchorB = _params.b;
    if (anchorA == null || anchorB == null) return null;
    if (anchorA.page.pageNumber != anchorB.page.pageNumber) return null;

    final pageText = anchorA.page;
    final start = math.min(anchorA.index, anchorB.index);
    final end = math.max(anchorA.index, anchorB.index) + 1;
    final charRects = pageText.charRects
        .map((rect) => rect.toDocumentRect())
        .toList();

    return DocumentHighlightDraft(
      pageNumber: pageText.pageNumber,
      startIndex: start,
      endIndex: end,
      text: pageText.fullText.substring(start, end),
      rects: DocumentHighlight.lineRects(charRects, start, end),
    );
  }
}
