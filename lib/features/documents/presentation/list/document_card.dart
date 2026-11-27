import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';
import 'package:reader_documents/features/documents/data/models/document_file.dart';
import 'package:reader_documents/l10n/app_localizations.dart';

import '../../application/documents_providers.dart';
import 'document_thumbnail.dart';

class DocumentCard extends ConsumerWidget {
  const DocumentCard({
    required this.file,
    this.onTap,
    this.onLongPress,
    this.selectionMode = false,
    this.selected = false,
    this.tile = false,
    super.key,
  });

  static const _maxVisibleTags = 2;

  final DocumentFile file;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool selectionMode;
  final bool selected;
  final bool tile;

  String _meta(Iterable<String> tags, String? pages) {
    final hidden = tags.length - _maxVisibleTags;
    return [
      file.formattedSize,
      ?pages,
      ...tags.take(_maxVisibleTags).map((tag) => '#$tag'),
      if (hidden > 0) '+$hidden',
    ].join(' · ');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tags = ref.watch(documentTagsProvider(file.path));
    final title = ref.watch(documentTitleProvider(file.path)) ?? file.name;
    final isFavorite = ref.watch(isFavoriteProvider(file.path));
    final progress = ref.watch(readingFractionProvider(file.path));
    final l10n = AppLocalizations.of(context)!;
    final pageCount = ref.watch(pageCountProvider(file.path)).value;
    final pages = pageCount != null && pageCount > 0
        ? l10n.pageCountShort(pageCount)
        : null;
    final meta = _meta(tile ? const <String>[] : tags, pages);

    return Semantics(
      selected: selectionMode ? selected : null,
      label: isFavorite ? l10n.addedToFavorites : null,
      child: tile
          ? AppDocumentCard(
              title: title,
              meta: meta,
              format: file.type.label,
              favorite: isFavorite,
              progress: progress,
              thumbnail: DocumentThumbnail.of(file),
              heroTag: DocumentPageHeroTag.of(file),
              scanned: file.type == DocumentType.djvu,
              selected: selectionMode ? selected : null,
              onTap: onTap,
              onLongPress: onLongPress,
              semanticsHint: l10n.documentCardHint,
            )
          : AppDocumentRow(
              title: title,
              meta: meta,
              format: file.type.label,
              favorite: isFavorite,
              progress: progress,
              thumbnail: DocumentThumbnail.of(file),
              heroTag: DocumentPageHeroTag.of(file),
              scanned: file.type == DocumentType.djvu,
              selected: selectionMode ? selected : null,
              onTap: onTap,
              onLongPress: onLongPress,
              semanticsHint: l10n.documentCardHint,
            ),
    );
  }
}

class DocumentCardSkeleton extends StatelessWidget {
  const DocumentCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.fromLTRB(
      AppSpacing.lg,
      AppSpacing.sm,
      AppSpacing.lg,
      AppSpacing.sm,
    ),
    child: Row(
      spacing: AppSpacing.md,
      children: [
        AppSkeleton(width: 42, height: 59),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: AppSpacing.sm,
            children: [
              AppSkeleton(width: 180, height: 14),
              AppSkeleton(width: 110, height: 10),
            ],
          ),
        ),
      ],
    ),
  );
}
