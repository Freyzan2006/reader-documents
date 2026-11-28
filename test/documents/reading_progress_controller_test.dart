import 'package:flutter_test/flutter_test.dart';
import 'package:reader_documents/features/documents/application/controllers/reading_progress_controller.dart';
import 'package:reader_documents/features/documents/data/repositories/reading_progress_repository.dart';

final class _MemoryRepository extends ReadingProgressRepository {
  final saved = <String, int>{};

  @override
  Future<int?> load(String documentPath) async => saved[documentPath];

  @override
  Future<void> save(String documentPath, int value) async =>
      saved[documentPath] = value;
}

void main() {
  late _MemoryRepository repository;
  var reports = 0;

  ReadingProgressController controller() => ReadingProgressController.page(
    repository: repository,
    documentPath: 'doc.pdf',
    onSaved: () => reports++,
  );

  setUp(() {
    repository = _MemoryRepository();
    reports = 0;
  });

  test('dispose writes the pending page and reports only afterwards', () async {
    controller()
      ..onPageChanged(3)
      ..dispose();
    expect(reports, 0);

    await pumpEventQueue();
    expect(repository.saved['doc.pdf'], 3);
    expect(reports, 1);
  });

  test('nothing pending means nothing to report', () async {
    controller().dispose();
    await pumpEventQueue();
    expect(reports, 0);
  });
}
