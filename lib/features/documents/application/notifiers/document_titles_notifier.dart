import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/documents_providers.dart';

class DocumentTitlesNotifier extends AsyncNotifier<Map<String, String>> {
  @override
  Future<Map<String, String>> build() =>
      ref.read(documentTitlesRepositoryProvider).loadAll();

  Future<void> setTitle(String documentPath, String title) async {
    final normalized = title.trim();
    final current = state.value ?? const {};
    if (normalized.isEmpty) {
      await ref.read(documentTitlesRepositoryProvider).clear(documentPath);
      state = AsyncData({...current}..remove(documentPath));
      return;
    }
    await ref
        .read(documentTitlesRepositoryProvider)
        .save(documentPath, normalized);
    state = AsyncData({...current, documentPath: normalized});
  }
}

final documentTitlesProvider =
    AsyncNotifierProvider<DocumentTitlesNotifier, Map<String, String>>(
      DocumentTitlesNotifier.new,
    );
