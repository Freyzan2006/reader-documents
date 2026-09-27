import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reader_documents/features/documents/data/models/tag_color.dart';

import '../providers/documents_providers.dart';
import 'tag_definitions_notifier.dart';

class TagsNotifier extends AsyncNotifier<Map<String, List<String>>> {
  @override
  Future<Map<String, List<String>>> build() =>
      ref.read(tagsRepositoryProvider).loadAll();

  Future<void> addTag(String documentPath, String tag, TagColor color) async {
    final normalized = tag.trim();
    if (normalized.isEmpty) return;
    final current = state.value ?? const {};
    final existing = current[documentPath] ?? const [];
    if (!existing.contains(normalized)) {
      final updated = [...existing, normalized];
      await ref.read(tagsRepositoryProvider).save(documentPath, updated);
      state = AsyncData({...current, documentPath: updated});
    }
    await ref.read(tagDefinitionsProvider.notifier).upsert(normalized, color);
  }

  Future<void> removeTag(String documentPath, String tag) async {
    final current = state.value ?? const {};
    final updated = (current[documentPath] ?? const [])
        .where((t) => t != tag)
        .toList();
    await ref.read(tagsRepositoryProvider).save(documentPath, updated);
    state = AsyncData({...current, documentPath: updated});
  }
}

final tagsProvider =
    AsyncNotifierProvider<TagsNotifier, Map<String, List<String>>>(
      TagsNotifier.new,
    );
