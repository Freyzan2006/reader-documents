import 'package:reader_documents/core/storage/json_document_store.dart';

import 'document_highlight.dart';

class HighlightsRepository extends JsonDocumentStore<List<DocumentHighlight>> {
  const HighlightsRepository();

  @override
  String get keyPrefix => 'highlights.';

  @override
  Object? encode(List<DocumentHighlight> value) =>
      value.map((h) => h.toJson()).toList();

  @override
  List<DocumentHighlight> decode(Object? json) => (json as List<dynamic>)
      .map((entry) => DocumentHighlight.fromJson(entry as Map<String, dynamic>))
      .toList();
}
