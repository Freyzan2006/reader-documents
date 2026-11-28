import 'package:flutter/foundation.dart';
import 'package:reader_documents/features/documents/data/models/document_highlight.dart';
import 'package:reader_documents/features/documents/data/repositories/highlights_repository.dart';

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

  Future<DocumentHighlight> add(
    DocumentHighlightDraft draft,
    DocumentHighlightColor color, {
    String note = '',
  }) async {
    final highlight = DocumentHighlight.fromDraft(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      draft: draft,
      color: color,
      note: note,
    );
    value = [...value, highlight];
    await _repository.save(_documentPath, value);
    return highlight;
  }

  Future<void> recolor(
    DocumentHighlight highlight,
    DocumentHighlightColor color,
  ) => _replace(highlight, (h) => h.copyWith(color: color));

  Future<void> setNote(DocumentHighlight highlight, String note) =>
      _replace(highlight, (h) => h.copyWith(note: note.trim()));

  Future<void> _replace(
    DocumentHighlight highlight,
    DocumentHighlight Function(DocumentHighlight) transform,
  ) async {
    value = [
      for (final h in value)
        if (h.id == highlight.id) transform(h) else h,
    ];
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
