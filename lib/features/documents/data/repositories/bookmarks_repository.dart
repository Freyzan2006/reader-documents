import 'package:reader_documents/core/storage/json_document_store.dart';

import '../models/document_bookmark.dart';

class BookmarksRepository extends JsonDocumentStore<List<DocumentBookmark>> {
  const BookmarksRepository();

  @override
  String get keyPrefix => 'bookmarks.';

  @override
  Object? encode(List<DocumentBookmark> value) =>
      value.map((b) => b.toJson()).toList();

  @override
  List<DocumentBookmark> decode(Object? json) => (json as List<dynamic>)
      .map((entry) => DocumentBookmark.fromJson(entry as Map<String, dynamic>))
      .toList();
}
