import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:reader_documents/features/documents/data/document_file.dart';
import 'package:reader_documents/features/documents/data/documents_repository.dart';
import 'package:reader_documents/features/documents/data/reading_progress_repository.dart';

import 'document_filter.dart';

final documentsRepositoryProvider = Provider<DocumentsRepository>(
  (ref) => const DocumentsRepository(),
);

final readingProgressRepositoryProvider = Provider<ReadingProgressRepository>(
  (ref) => const ReadingProgressRepository(),
);

final documentFilterProvider = StateProvider<DocumentFilter>(
  (ref) => const DocumentFilter(),
);

class DocumentsNotifier extends AsyncNotifier<List<DocumentFile>> {
  @override
  Future<List<DocumentFile>> build() =>
      ref.read(documentsRepositoryProvider).list();

  Future<void> refresh() async {
    state = await AsyncValue.guard(
      () => ref.read(documentsRepositoryProvider).list(),
    );
  }

  Future<DocumentFile> import(String sourcePath) async {
    final file = await ref.read(documentsRepositoryProvider).import(sourcePath);
    await refresh();
    return file;
  }

  Future<void> delete(String path) async {
    await ref.read(documentsRepositoryProvider).delete(path);
    await refresh();
  }
}

final documentsProvider =
    AsyncNotifierProvider<DocumentsNotifier, List<DocumentFile>>(
      DocumentsNotifier.new,
    );

final filteredDocumentsProvider = Provider<AsyncValue<List<DocumentFile>>>((
  ref,
) {
  final filter = ref.watch(documentFilterProvider);
  final documents = ref.watch(documentsProvider);
  return documents.whenData(
    (files) => files.where((file) => filter.matches(file.type)).toList(),
  );
});
