import 'package:reader_documents/features/documents/data/models/document_file.dart';
import 'package:reader_documents/features/documents/data/repositories/favorites_repository.dart';

class FakeFavoritesRepository extends FavoritesRepository {
  final Map<String, bool> values = {};

  @override
  Future<Map<String, bool>> loadAll() async => Map.of(values);

  @override
  Future<void> save(String documentPath, bool value) async =>
      values[documentPath] = value;

  @override
  Future<void> clear(String documentPath) async => values.remove(documentPath);
}

final testDocuments = [
  DocumentFile(
    path: '/docs/a.pdf',
    name: 'a.pdf',
    type: DocumentType.pdf,
    sizeBytes: 1024,
    modifiedAt: DateTime(2026),
  ),
  DocumentFile(
    path: '/docs/b.pdf',
    name: 'b.pdf',
    type: DocumentType.pdf,
    sizeBytes: 2048,
    modifiedAt: DateTime(2026),
  ),
];
