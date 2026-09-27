import 'package:reader_documents/core/storage/json_document_store.dart';

class FavoritesRepository extends JsonDocumentStore<bool> {
  const FavoritesRepository();

  @override
  String get keyPrefix => 'document_favorite.';

  @override
  Object? encode(bool value) => value;

  @override
  bool decode(Object? json) => json as bool;
}
