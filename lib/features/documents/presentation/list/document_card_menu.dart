import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';
import 'package:reader_documents/features/documents/data/models/document_file.dart';
import 'package:reader_documents/l10n/app_localizations.dart';

import '../../application/documents_providers.dart';
import '../actions/document_commands.dart';
import '../actions/document_rename.dart';
import '../actions/document_sharing.dart';
import '../tags/tag_editor.dart';

abstract final class DocumentCardMenu {
  static Future<void> show({
    required BuildContext context,
    required WidgetRef ref,
    required DocumentFile file,
    required Future<bool> Function() confirmDelete,
    required VoidCallback onDelete,
    VoidCallback? onSelectMultiple,
  }) => AppSheet.showContent<void>(
    context: context,
    builder: (sheetContext, scrollController) => _DocumentCardMenuView(
      actionContext: context,
      file: file,
      scrollController: scrollController,
      confirmDelete: confirmDelete,
      onDelete: onDelete,
      onSelectMultiple: onSelectMultiple,
    ),
  );
}

class _DocumentCardMenuView extends ConsumerWidget {
  const _DocumentCardMenuView({
    required this.actionContext,
    required this.file,
    required this.scrollController,
    required this.confirmDelete,
    required this.onDelete,
    this.onSelectMultiple,
  });

  final BuildContext actionContext;
  final DocumentFile file;
  final ScrollController scrollController;
  final Future<bool> Function() confirmDelete;
  final VoidCallback onDelete;
  final VoidCallback? onSelectMultiple;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final title = ref.watch(documentTitleProvider(file.path)) ?? file.name;
    final isFavorite = ref.watch(isFavoriteProvider(file.path));

    void closeAnd(VoidCallback action) {
      Navigator.of(context).pop();
      action();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: AppSpacing.xs,
            children: [
              AppText(l10n.documentActionsTitle, variant: AppTextVariant.title),
              AppText(
                title,
                variant: AppTextVariant.annotation,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        Flexible(
          child: ListView(
            controller: scrollController,
            shrinkWrap: true,
            children: [
              AppList(
                framed: false,
                items: [
                  AppListItem(
                    title: isFavorite
                        ? l10n.removeFromFavoritesAction
                        : l10n.addToFavoritesAction,
                    leading: AppIcons.star,
                    onTap: () => closeAnd(
                      () async => DocumentCommands.toggleFavorite(
                        actionContext,
                        ref,
                        file,
                      ),
                    ),
                  ),
                  if (onSelectMultiple != null)
                    AppListItem(
                      title: l10n.selectMultiple,
                      leading: AppIcons.listChecks,
                      onTap: () => closeAnd(() => onSelectMultiple!()),
                    ),
                  AppListItem(
                    title: l10n.pdfMenuRename,
                    leading: AppIcons.pencil,
                    onTap: () => closeAnd(
                      () async => DocumentRename.show(
                        context: actionContext,
                        ref: ref,
                        file: file,
                      ),
                    ),
                  ),
                  AppListItem(
                    title: l10n.tagsTitle,
                    leading: AppIcons.tags,
                    onTap: () => closeAnd(
                      () async => TagEditorSheet.show(
                        context: actionContext,
                        documentPath: file.path,
                      ),
                    ),
                  ),
                  AppListItem(
                    title: l10n.pdfMenuShare,
                    leading: AppIcons.share2,
                    onTap: () =>
                        closeAnd(() async => DocumentSharing.share(file)),
                  ),
                  AppListItem(
                    title: l10n.delete,
                    leading: AppIcons.trash,
                    destructive: true,
                    onTap: () => closeAnd(() async {
                      if (await confirmDelete()) onDelete();
                    }),
                  ),
                ],
              ),
              const AppGap.lg(),
            ],
          ),
        ),
      ],
    );
  }
}
