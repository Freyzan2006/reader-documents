import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';
import 'package:reader_documents/features/documents/data/models/document_file.dart';
import 'package:reader_documents/features/documents/data/models/tag_color.dart';
import 'package:reader_documents/l10n/app_localizations.dart';

import '../../application/documents_providers.dart';
import 'document_icon.dart';

class DocumentCard extends ConsumerWidget {
  const DocumentCard({
    required this.file,
    this.onTap,
    this.onLongPress,
    this.selectionMode = false,
    this.selected = false,
    super.key,
  });

  static const _maxVisibleTags = 2;

  final DocumentFile file;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool selectionMode;
  final bool selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tags = ref.watch(documentTagsProvider(file.path));
    final title = ref.watch(documentTitleProvider(file.path)) ?? file.name;
    final isFavorite = ref.watch(isFavoriteProvider(file.path));
    final l10n = AppLocalizations.of(context)!;

    return Semantics(
      selected: selectionMode ? selected : null,
      child: AppTappable(
        onPressed: onTap,
        onLongPress: onLongPress,
        selected: selectionMode && selected,
        semanticsHint: l10n.documentCardHint,
        child: AppCard(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            spacing: AppSpacing.sm,
            children: [
              if (selectionMode)
                AppSelectionBadge(selected: selected)
              else
                DocumentIcon(type: file.type),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: AppSpacing.xs,
                  children: [
                    AppText(
                      title,
                      variant: AppTextVariant.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      spacing: AppSpacing.xs,
                      children: [
                        AppBadge(
                          variant: AppBadgeVariant.secondary,
                          child: Text(file.type.label),
                        ),
                        AppBadge(
                          variant: AppBadgeVariant.outline,
                          child: Text(file.formattedSize),
                        ),
                      ],
                    ),
                    if (tags.isNotEmpty)
                      Wrap(
                        spacing: AppSpacing.xs,
                        runSpacing: AppSpacing.xs,
                        children: [
                          for (final tag in tags.take(_maxVisibleTags))
                            AppBadge(
                              color: ref.watch(tagColorProvider(tag)).value,
                              child: Text(tag),
                            ),
                          if (tags.length > _maxVisibleTags)
                            AppBadge(
                              variant: AppBadgeVariant.outline,
                              child: Text('+${tags.length - _maxVisibleTags}'),
                            ),
                        ],
                      ),
                  ],
                ),
              ),
              if (isFavorite)
                Semantics(
                  label: l10n.addedToFavorites,
                  child: Icon(
                    AppIcons.star,
                    size: 20,
                    color: AppColors.warning(context),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class DocumentCardSkeleton extends StatelessWidget {
  const DocumentCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) => AppCard(
    padding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.md,
      vertical: AppSpacing.md,
    ),
    child: Row(
      spacing: AppSpacing.sm,
      children: [
        const AppSkeleton.circle(size: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: AppSpacing.xs,
            children: const [
              AppSkeleton(width: 140, height: 16),
              Row(
                mainAxisSize: MainAxisSize.min,
                spacing: AppSpacing.xs,
                children: [
                  AppSkeleton(width: 48, height: 22),
                  AppSkeleton(width: 68, height: 22),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
