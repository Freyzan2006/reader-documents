import 'package:flutter/foundation.dart';
import 'package:reader_documents/features/documents/data/document_highlight.dart';
import 'package:reader_documents/features/documents/data/highlights_repository.dart';

class DocumentHighlightsController
    extends ValueNotifier<List<DocumentHighlight>> {
  DocumentHighlightsController(this._repository, this._documentPath)
    : super(const []);

  final HighlightsRepository _repository;
  final String _documentPath;

  Future<void> load() async {
    final highlights = await _repository.load(_documentPath);
    value = highlights ?? const [];
  }

  Future<void> add(
    DocumentHighlightDraft draft,
    DocumentHighlightColor color,
  ) async {
    final highlight = DocumentHighlight.fromDraft(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      draft: draft,
      color: color,
    );
    value = [...value, highlight];
    await _repository.save(_documentPath, value);
  }

  Future<void> remove(DocumentHighlight highlight) async {
    value = value.where((h) => h.id != highlight.id).toList();
    await _repository.save(_documentPath, value);
  }

  DocumentHighlight? findOverlapping(int pageNumber, int start, int end) {
    for (final highlight in value) {
      if (highlight.overlapsRange(pageNumber, start, end)) return highlight;
    }
    return null;
  }
}
