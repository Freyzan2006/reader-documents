import 'package:reader_documents/core/storage/json_document_store.dart';

class RecentlyOpenedRepository extends JsonDocumentStore<DateTime> {
  const RecentlyOpenedRepository();

  @override
  String get keyPrefix => 'document_recently_opened.';

  @override
  Object? encode(DateTime value) => value.toIso8601String();

  @override
  DateTime decode(Object? json) => DateTime.parse(json as String);
}
