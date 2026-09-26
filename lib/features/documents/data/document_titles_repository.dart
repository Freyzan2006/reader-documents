import 'package:reader_documents/core/storage/json_document_store.dart';

/// Per-document display-name override, shown in place of the file's actual
/// name. The underlying file is never touched — reading progress, highlights
/// and tags all stay keyed by the original, unchanged file path.
class DocumentTitlesRepository extends JsonDocumentStore<String> {
  const DocumentTitlesRepository();

  @override
  String get keyPrefix => 'document_title.';

  @override
  Object? encode(String value) => value;

  @override
  String decode(Object? json) => json as String;
}
