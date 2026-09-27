import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reader_documents/features/documents/data/models/document_file.dart';

import '../providers/documents_providers.dart';

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
