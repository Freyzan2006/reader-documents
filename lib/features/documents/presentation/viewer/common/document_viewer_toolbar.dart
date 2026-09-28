import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';
import 'package:reader_documents/features/documents/application/documents_providers.dart';
import 'package:reader_documents/features/documents/data/models/document_file.dart';
import 'package:reader_documents/l10n/app_localizations.dart';

import '../../actions/document_rename.dart';
import '../../actions/document_sharing.dart';
import '../contract/document_viewer_controller.dart';
import 'document_minimap.dart';
import 'rotated_reading_edge.dart';

class DocumentViewerToolbar extends ConsumerWidget {
  const DocumentViewerToolbar({
    required this.file,
    required this.title,
    required this.viewerController,
    required this.onSearch,
    required this.onRotate,
    required this.onScreenshot,
    required this.isBookmarked,
    required this.onToggleBookmark,
    required this.onShowNotes,
    this.onExportNotes,
    this.quarterTurns = 0,
    super.key,
  });

  final DocumentFile file;
  final String title;
  final DocumentViewerController? viewerController;
  final VoidCallback onSearch;
  final VoidCallback onRotate;
  final VoidCallback onScreenshot;
  final bool isBookmarked;
  final VoidCallback onToggleBookmark;
  final VoidCallback onShowNotes;

  /// Null when there's nothing (no bookmarks, no highlights) to export yet.
  final VoidCallback? onExportNotes;

  /// How many quarter turns this toolbar is itself displayed rotated by (an
  /// ancestor `RotatedBox`). When rotated, the overflow menu shows as a
  /// bottom sheet instead of an anchored popover — a popover positions
  /// itself from the trigger's on-screen transform, which forui's portal
  /// system gets wrong once that transform includes a rotation; a sheet
  /// anchors to the true screen bounds instead, sidestepping the issue.
  final int quarterTurns;

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
        if (viewerController != null)
          AppIconButton(
            icon: isBookmarked ? AppIcons.bookmarkCheck : AppIcons.bookmark,
            onPressed: onToggleBookmark,
            color: isBookmarked ? AppColors.accent(context) : null,
          ),
        _OverflowMenu(
          quarterTurns: quarterTurns,
          items: [
            AppCommandItem(
              label: l10n.pdfMenuRotate,
              icon: AppIcons.rotateCw,
              onSelect: onRotate,
            ),
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
            if (controller != null)
              AppCommandItem(
                label: l10n.pdfMenuNotes,
                icon: AppIcons.tableOfContents,
                onSelect: onShowNotes,
              ),
            if (controller != null)
              AppCommandItem(
                label: l10n.pdfMenuPages,
                icon: AppIcons.layoutGrid,
                onSelect: () => DocumentMinimapSheet.show(
                  context: context,
                  controller: controller,
                  fileFormatLabel: file.type.label,
                  quarterTurns: quarterTurns,
                ),
              ),
            AppCommandItem(
              label: l10n.pdfMenuShare,
              icon: AppIcons.share2,
              onSelect: () => DocumentSharing.share(file),
            ),
            AppCommandItem(
              label: l10n.pdfMenuScreenshot,
              icon: AppIcons.camera,
              onSelect: onScreenshot,
            ),
            if (onExportNotes != null)
              AppCommandItem(
                label: l10n.pdfMenuExportNotes,
                icon: AppIcons.download,
                onSelect: onExportNotes!,
              ),
          ],
        ),
      ],
    );
  }
}

class _OverflowMenu extends StatelessWidget {
  const _OverflowMenu({required this.quarterTurns, required this.items});

  final int quarterTurns;
  final List<AppCommandItem> items;

  static const _trigger = AppIconButton(
    icon: AppIcons.ellipsisVertical,
    onPressed: null,
    enabled: true,
  );

  @override
  Widget build(BuildContext context) => quarterTurns != 0
      ? AppIconButton(
          icon: AppIcons.ellipsisVertical,
          onPressed: () => AppCommandSidePanel.show(
            context: context,
            items: items,
            side: rotatedReadingBottomEdge(quarterTurns),
            quarterTurns: quarterTurns,
          ),
        )
      : AppPopoverMenu(items: items, child: _trigger);
}
