import 'package:reader_documents/features/documents/application/providers/gesture_hint.dart';
import 'package:reader_documents/features/documents/data/models/document_file.dart';
import 'package:reader_documents/features/documents/data/repositories/favorites_repository.dart';
import 'package:reader_documents/features/documents/data/repositories/page_count_repository.dart';

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

class FakePageCountRepository extends PageCountRepository {
  FakePageCountRepository(this.counts);

  final Map<String, int> counts;

  @override
  Future<int?> load(String documentPath) async => counts[documentPath];
}

class FakeGestureHintRepository extends GestureHintRepository {
  FakeGestureHintRepository([this.seen = false]);

  bool seen;

  @override
  Future<bool?> load() async => seen;

  @override
  Future<void> save(bool value) async => seen = value;

  @override
  Future<void> clear() async => seen = false;
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
