import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';
import 'package:reader_documents/l10n/app_localizations.dart';

import '../../application/documents_providers.dart';
import '../../data/models/document_file.dart';
import '../list/document_mini_thumbnail.dart';
import 'document_commands.dart';

abstract final class DocumentSearchItems {
  static const _searchLimit = 30;

  static List<AppCommandItem> recent(BuildContext context, WidgetRef ref) => [
    for (final file in ref.read(recentDocumentsProvider).value ?? const [])
      _item(context, ref, file),
  ];

  static List<AppCommandItem> search(
    BuildContext context,
    WidgetRef ref,
    String query, {
    int limit = _searchLimit,
  }) {
    final files = ref.read(documentsProvider).value ?? const <DocumentFile>[];
    final lower = query.trim().toLowerCase();
    if (lower.isEmpty) return const [];

    final items = <AppCommandItem>[];
    for (final file in files) {
      final title = ref.read(documentTitleProvider(file.path)) ?? file.name;
      final tags = ref.read(documentTagsProvider(file.path));
      if (!_matches(lower, file.name, title, tags)) continue;
      items.add(_item(context, ref, file, title: title, tags: tags));
      if (items.length >= limit) break;
    }
    return items;
  }

  static bool _matches(
    String lower,
    String name,
    String title,
    List<String> tags,
  ) =>
      title.toLowerCase().contains(lower) ||
      name.toLowerCase().contains(lower) ||
      tags.any((tag) => tag.toLowerCase().contains(lower));

  static String _place(AppLocalizations l10n, WidgetRef ref, String path) {
    final page = ref.read(lastReadingProgressPageProvider(path)).value;
    final count = ref.read(pageCountProvider(path)).value;
    if (count == null || count <= 0) return '';
    if (page == null || page <= 0) return l10n.pageCountShort(count);
    return l10n.pageOfCount(page.clamp(1, count), count);
  }

  static AppCommandItem _item(
    BuildContext context,
    WidgetRef ref,
    DocumentFile file, {
    String? title,
    List<String>? tags,
  }) {
    final l10n = AppLocalizations.of(context)!;
    final List<String> resolvedTags =
        tags ?? ref.read(documentTagsProvider(file.path));
    final place = _place(l10n, ref, file.path);

    return AppCommandItem(
      label: title ?? ref.read(documentTitleProvider(file.path)) ?? file.name,
      leading: DocumentMiniThumbnail(file: file),
      subtitle: [
        file.type.label,
        if (place.isNotEmpty) place,
        ...resolvedTags.map((tag) => '#$tag'),
      ].join(' · '),
      keywords: [file.name, ...resolvedTags],
      onSelect: () => DocumentCommands.open(context, ref, file),
    );
  }
}
