import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';
import 'package:reader_documents/l10n/app_localizations.dart';

import '../../application/documents_providers.dart';
import '../../data/models/document_file.dart';
import '../list/document_mini_thumbnail.dart';
import 'document_commands.dart';

abstract final class DocumentSearchItems {
  static List<AppCommandItem> recent(BuildContext context, WidgetRef ref) => [
    for (final file in ref.read(recentDocumentsProvider).value ?? const [])
      _item(context, ref, file),
  ];

  static List<AppCommandItem> all(BuildContext context, WidgetRef ref) => [
    for (final file in ref.read(documentsProvider).value ?? const [])
      _item(context, ref, file),
  ];

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
    DocumentFile file,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final tags = ref.read(documentTagsProvider(file.path));
    final place = _place(l10n, ref, file.path);

    return AppCommandItem(
      label: ref.read(documentTitleProvider(file.path)) ?? file.name,
      leading: DocumentMiniThumbnail(file: file),
      subtitle: [
        file.type.label,
        if (place.isNotEmpty) place,
        ...tags.map((tag) => '#$tag'),
      ].join(' · '),
      keywords: [file.name, ...tags],
      onSelect: () => DocumentCommands.open(context, ref, file),
    );
  }
}
