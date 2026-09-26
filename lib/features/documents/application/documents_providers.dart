import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:reader_documents/features/documents/data/document_file.dart';
import 'package:reader_documents/features/documents/data/document_titles_repository.dart';
import 'package:reader_documents/features/documents/data/documents_repository.dart';
import 'package:reader_documents/features/documents/data/favorites_repository.dart';
import 'package:reader_documents/features/documents/data/highlights_repository.dart';
import 'package:reader_documents/features/documents/data/reading_progress_repository.dart';
import 'package:reader_documents/features/documents/data/recently_opened_repository.dart';
import 'package:reader_documents/features/documents/data/tag_color.dart';
import 'package:reader_documents/features/documents/data/tag_definition.dart';
import 'package:reader_documents/features/documents/data/tag_definitions_repository.dart';
import 'package:reader_documents/features/documents/data/tags_repository.dart';

import 'document_filter.dart';

final documentsRepositoryProvider = Provider<DocumentsRepository>(
  (ref) => const DocumentsRepository(),
);

final readingProgressRepositoryProvider = Provider<ReadingProgressRepository>(
  (ref) => const ReadingProgressRepository(),
);

final highlightsRepositoryProvider = Provider<HighlightsRepository>(
  (ref) => const HighlightsRepository(),
);

final tagsRepositoryProvider = Provider<TagsRepository>(
  (ref) => const TagsRepository(),
);

final tagDefinitionsRepositoryProvider = Provider<TagDefinitionsRepository>(
  (ref) => const TagDefinitionsRepository(),
);

class TagDefinitionsNotifier extends AsyncNotifier<List<TagDefinition>> {
  @override
  Future<List<TagDefinition>> build() =>
      ref.read(tagDefinitionsRepositoryProvider).load();

  Future<void> upsert(String name, TagColor color) async {
    final current = state.value ?? const [];
    final updated = [
      for (final definition in current)
        if (definition.name != name) definition,
      TagDefinition(name: name, color: color),
    ];
    await ref.read(tagDefinitionsRepositoryProvider).save(updated);
    state = AsyncData(updated);
  }
}

final tagDefinitionsProvider =
    AsyncNotifierProvider<TagDefinitionsNotifier, List<TagDefinition>>(
      TagDefinitionsNotifier.new,
    );

final tagColorProvider = Provider.family<TagColor, String>((ref, name) {
  final definitions = ref.watch(tagDefinitionsProvider).value ?? const [];
  for (final definition in definitions) {
    if (definition.name == name) return definition.color;
  }
  return TagColor.gray;
});

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

final documentTagsProvider = Provider.family<List<String>, String>((
  ref,
  documentPath,
) {
  final tags = ref.watch(tagsProvider).value;
  return tags?[documentPath] ?? const [];
});

final documentTitlesRepositoryProvider = Provider<DocumentTitlesRepository>(
  (ref) => const DocumentTitlesRepository(),
);

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

final documentTitleProvider = Provider.family<String?, String>((
  ref,
  documentPath,
) {
  final titles = ref.watch(documentTitlesProvider).value;
  return titles?[documentPath];
});

final favoritesRepositoryProvider = Provider<FavoritesRepository>(
  (ref) => const FavoritesRepository(),
);

class FavoritesNotifier extends AsyncNotifier<Set<String>> {
  @override
  Future<Set<String>> build() async {
    final all = await ref.read(favoritesRepositoryProvider).loadAll();
    return all.keys.toSet();
  }

  Future<void> toggle(String documentPath) async {
    final current = state.value ?? const {};
    final repo = ref.read(favoritesRepositoryProvider);
    if (current.contains(documentPath)) {
      await repo.clear(documentPath);
      state = AsyncData({...current}..remove(documentPath));
    } else {
      await repo.save(documentPath, true);
      state = AsyncData({...current, documentPath});
    }
  }
}

final favoritesProvider = AsyncNotifierProvider<FavoritesNotifier, Set<String>>(
  FavoritesNotifier.new,
);

final isFavoriteProvider = Provider.family<bool, String>((ref, documentPath) {
  final favorites = ref.watch(favoritesProvider).value;
  return favorites?.contains(documentPath) ?? false;
});

final recentlyOpenedRepositoryProvider = Provider<RecentlyOpenedRepository>(
  (ref) => const RecentlyOpenedRepository(),
);

class RecentlyOpenedNotifier extends AsyncNotifier<Map<String, DateTime>> {
  @override
  Future<Map<String, DateTime>> build() =>
      ref.read(recentlyOpenedRepositoryProvider).loadAll();

  Future<void> markOpened(String documentPath) async {
    final repository = ref.read(recentlyOpenedRepositoryProvider);
    await repository.save(documentPath, DateTime.now());
    state = AsyncData({
      ...state.value ?? const {},
      documentPath: DateTime.now(),
    });
  }
}

final recentlyOpenedProvider =
    AsyncNotifierProvider<RecentlyOpenedNotifier, Map<String, DateTime>>(
      RecentlyOpenedNotifier.new,
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
  final query = filter.query.trim().toLowerCase();

  return documents.whenData(
    (files) => files.where((file) {
      if (!filter.matches(file.type)) return false;
      if (query.isEmpty) return true;
      final title = ref.watch(documentTitleProvider(file.path)) ?? file.name;
      return title.toLowerCase().contains(query);
    }).toList(),
  );
});

const recentDocumentsLimit = 4;

final recentDocumentsProvider = Provider<AsyncValue<List<DocumentFile>>>((ref) {
  final documents = ref.watch(documentsProvider);
  final recentlyOpened = ref.watch(recentlyOpenedProvider).value ?? const {};

  return documents.whenData((files) {
    final opened =
        files.where((file) => recentlyOpened.containsKey(file.path)).toList()
          ..sort(
            (a, b) =>
                recentlyOpened[b.path]!.compareTo(recentlyOpened[a.path]!),
          );
    return opened.take(recentDocumentsLimit).toList();
  });
});
