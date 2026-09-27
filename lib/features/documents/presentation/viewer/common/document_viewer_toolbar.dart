import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';
import 'package:reader_documents/features/documents/application/documents_providers.dart';
import 'package:reader_documents/features/documents/data/document_file.dart';
import 'package:reader_documents/l10n/app_localizations.dart';

import '../../actions/document_rename.dart';
import '../../actions/document_sharing.dart';
import '../contract/document_viewer_controller.dart';
import 'document_minimap.dart';
import 'document_outline.dart';

class DocumentViewerToolbar extends ConsumerWidget {
  const DocumentViewerToolbar({
    required this.file,
    required this.title,
    required this.viewerController,
    required this.onSearch,
    super.key,
  });

  final DocumentFile file;
  final String title;
  final DocumentViewerController? viewerController;
  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final controller = viewerController;

    return Row(
      spacing: AppSpacing.md,
      children: [
        AppIconButton(
          icon: AppIcons.arrowLeft,
          onPressed: () => Navigator.of(context).pop(),
        ),
        Expanded(
          child: Center(
            child: AppTooltip(
              tip: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title),
                  AppCopyText(
                    file.path,
                    variant: AppTextVariant.caption,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              child: AppCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                child: AppText(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
        ),
        AppIconButton(
          icon: AppIcons.star,
          onPressed: () =>
              ref.read(favoritesProvider.notifier).toggle(file.path),
          color: ref.watch(isFavoriteProvider(file.path))
              ? AppColors.warning(context)
              : null,
        ),
        AppPopoverMenu(
          items: [
            AppCommandItem(
              label: l10n.pdfMenuRename,
              icon: AppIcons.pencil,
              onSelect: () =>
                  DocumentRename.show(context: context, ref: ref, file: file),
            ),
            if (controller?.search != null)
              AppCommandItem(
                label: l10n.pdfMenuSearch,
                icon: AppIcons.search,
                onSelect: onSearch,
              ),
            if (controller?.outline.isNotEmpty ?? false)
              AppCommandItem(
                label: l10n.pdfMenuOutline,
                icon: AppIcons.tableOfContents,
                onSelect: () => DocumentOutlineSheet.show(
                  context: context,
                  controller: controller!,
                ),
              ),
            if (controller != null)
              AppCommandItem(
                label: l10n.pdfMenuPages,
                icon: AppIcons.layoutGrid,
                onSelect: () => DocumentMinimapSheet.show(
                  context: context,
                  controller: controller,
                  fileFormatLabel: file.type.label,
                ),
              ),
            AppCommandItem(
              label: l10n.pdfMenuShare,
              icon: AppIcons.share2,
              onSelect: () => DocumentSharing.share(file),
            ),
          ],
          child: const AppIconButton(
            icon: AppIcons.ellipsisVertical,
            onPressed: null,
            enabled: true,
          ),
        ),
      ],
    );
  }
}
