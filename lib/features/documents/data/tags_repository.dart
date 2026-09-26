import 'package:reader_documents/core/storage/json_document_store.dart';

class TagsRepository extends JsonDocumentStore<List<String>> {
  const TagsRepository();

  @override
  String get keyPrefix => 'document_tags.';

  @override
  Object? encode(List<String> value) => value;

  @override
  List<String> decode(Object? json) => (json as List<dynamic>).cast<String>();
}
