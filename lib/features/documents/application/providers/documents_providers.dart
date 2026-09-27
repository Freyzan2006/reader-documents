import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:reader_documents/features/documents/data/models/document_file.dart';
import 'package:reader_documents/features/documents/data/models/tag_color.dart';
import 'package:reader_documents/features/documents/data/repositories/document_titles_repository.dart';
import 'package:reader_documents/features/documents/data/repositories/documents_repository.dart';
import 'package:reader_documents/features/documents/data/repositories/favorites_repository.dart';
import 'package:reader_documents/features/documents/data/repositories/highlights_repository.dart';
import 'package:reader_documents/features/documents/data/repositories/reading_progress_repository.dart';
import 'package:reader_documents/features/documents/data/repositories/recently_opened_repository.dart';
import 'package:reader_documents/features/documents/data/repositories/tag_definitions_repository.dart';
import 'package:reader_documents/features/documents/data/repositories/tags_repository.dart';

import '../notifiers/document_titles_notifier.dart';
import '../notifiers/documents_notifier.dart';
import '../notifiers/favorites_notifier.dart';
import '../notifiers/recently_opened_notifier.dart';
import '../notifiers/tag_definitions_notifier.dart';
import '../notifiers/tags_notifier.dart';
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

final documentTitlesRepositoryProvider = Provider<DocumentTitlesRepository>(
  (ref) => const DocumentTitlesRepository(),
);

final favoritesRepositoryProvider = Provider<FavoritesRepository>(
  (ref) => const FavoritesRepository(),
);

final recentlyOpenedRepositoryProvider = Provider<RecentlyOpenedRepository>(
  (ref) => const RecentlyOpenedRepository(),
);

final documentFilterProvider = StateProvider<DocumentFilter>(
  (ref) => const DocumentFilter(),
);

final tagColorProvider = Provider.family<TagColor, String>((ref, name) {
  final definitions = ref.watch(tagDefinitionsProvider).value ?? const [];
  for (final definition in definitions) {
    if (definition.name == name) return definition.color;
  }
  return TagColor.gray;
});

final documentTagsProvider = Provider.family<List<String>, String>((
  ref,
  documentPath,
) {
  final tags = ref.watch(tagsProvider).value;
  return tags?[documentPath] ?? const [];
});

final documentTitleProvider = Provider.family<String?, String>((
  ref,
  documentPath,
) {
  final titles = ref.watch(documentTitlesProvider).value;
  return titles?[documentPath];
});

final isFavoriteProvider = Provider.family<bool, String>((ref, documentPath) {
  final favorites = ref.watch(favoritesProvider).value;
  return favorites?.contains(documentPath) ?? false;
});

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
