import 'package:reader_documents/core/storage/json_document_store.dart';

import 'pdf_highlight.dart';

class HighlightsRepository extends JsonDocumentStore<List<PdfHighlight>> {
  const HighlightsRepository();

  @override
  String get keyPrefix => 'pdf_highlights.';

  @override
  Object? encode(List<PdfHighlight> value) =>
      value.map((h) => h.toJson()).toList();

  @override
  List<PdfHighlight> decode(Object? json) => (json as List<dynamic>)
      .map((entry) => PdfHighlight.fromJson(entry as Map<String, dynamic>))
      .toList();
}
