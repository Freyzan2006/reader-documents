import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';
import 'package:reader_documents/features/documents/data/document_file.dart';
import 'package:reader_documents/features/documents/data/tag_color.dart';
import 'package:reader_documents/l10n/app_localizations.dart';

import '../application/documents_providers.dart';
import 'document_rename.dart';
import 'document_sharing.dart';
import 'tag_editor.dart';

class DocumentCard extends ConsumerWidget {
  const DocumentCard({
    required this.file,
    this.onTap,
    this.confirmDelete,
    this.onDelete,
    super.key,
  });

  static const _maxNameChars = 20;
  static const _maxVisibleTags = 2;

  final DocumentFile file;
  final VoidCallback? onTap;
  final Future<bool> Function(DocumentFile file)? confirmDelete;
  final ValueChanged<DocumentFile>? onDelete;

  String _displayName(String name) => name.length > _maxNameChars
      ? '${name.substring(0, _maxNameChars - 3)}...'
      : name;

  Future<void> _delete() async {
    if (confirmDelete == null || onDelete == null) return;
    if (await confirmDelete!(file)) onDelete!(file);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tags = ref.watch(documentTagsProvider(file.path));
    final title = ref.watch(documentTitleProvider(file.path)) ?? file.name;
    final isFavorite = ref.watch(isFavoriteProvider(file.path));
    final l10n = AppLocalizations.of(context)!;

    return AppTappable(
      onPressed: onTap,
      child: AppCard(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          spacing: AppSpacing.sm,
          children: [
            const Icon(AppIcons.fileText, size: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: AppSpacing.xs,
                children: [
                  AppText(_displayName(title)),
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
            AppIconButton(
              icon: AppIcons.star,
              onPressed: () =>
                  ref.read(favoritesProvider.notifier).toggle(file.path),
              color: isFavorite ? AppColors.warning(context) : null,
            ),
            AppPopoverMenu(
              items: [
                AppCommandItem(
                  label: l10n.pdfMenuRename,
                  icon: AppIcons.pencil,
                  onSelect: () => DocumentRename.show(
                    context: context,
                    ref: ref,
                    file: file,
                  ),
                ),
                AppCommandItem(
                  label: l10n.tagsTitle,
                  icon: AppIcons.tags,
                  onSelect: () => TagEditorSheet.show(
                    context: context,
                    documentPath: file.path,
                  ),
                ),
                AppCommandItem(
                  label: l10n.pdfMenuShare,
                  icon: AppIcons.share2,
                  onSelect: () => DocumentSharing.share(file),
                ),
                if (confirmDelete != null && onDelete != null)
                  AppCommandItem(
                    label: l10n.delete,
                    icon: AppIcons.trash,
                    onSelect: _delete,
                  ),
              ],
              child: const AppIconButton(
                icon: AppIcons.ellipsisVertical,
                onPressed: null,
                enabled: true,
              ),
            ),
          ],
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
      vertical: AppSpacing.sm,
    ),
    child: Row(
      spacing: AppSpacing.sm,
      children: [
        const AppSkeleton.circle(size: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: AppSpacing.xs,
            children: [
              const AppSkeleton(width: 120, height: 14),
              Row(
                mainAxisSize: MainAxisSize.min,
                spacing: AppSpacing.xs,
                children: const [
                  AppSkeleton(width: 40, height: 20),
                  AppSkeleton(width: 56, height: 20),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
