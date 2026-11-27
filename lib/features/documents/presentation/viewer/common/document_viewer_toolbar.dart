import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';
import 'package:reader_documents/features/documents/application/documents_providers.dart';
import 'package:reader_documents/features/documents/data/models/document_file.dart';
import 'package:reader_documents/l10n/app_localizations.dart';

import '../../actions/document_commands.dart';
import '../../actions/document_rename.dart';
import '../../actions/document_sharing.dart';
import '../contract/document_viewer_controller.dart';
import 'document_minimap.dart';

class DocumentViewerToolbar extends ConsumerWidget {
  const DocumentViewerToolbar({
    required this.file,
    required this.title,
    required this.viewerController,
    required this.onSearch,
    required this.onRotate,
    required this.onScreenshot,
    required this.onShowNotes,
    this.onExportNotes,
    super.key,
  });

  final DocumentFile file;
  final String title;
  final DocumentViewerController? viewerController;
  final VoidCallback onSearch;
  final VoidCallback onRotate;
  final VoidCallback onScreenshot;
  final VoidCallback onShowNotes;
  final VoidCallback? onExportNotes;

  String _meta(AppLocalizations l10n) {
    final controller = viewerController;
    return controller != null && controller.supportsPagination
        ? '${file.type.label} · ${l10n.pageCountShort(controller.pageCount)}'
        : file.type.label;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final controller = viewerController;
    final isFavorite = ref.watch(isFavoriteProvider(file.path));
    final onExportNotes = this.onExportNotes;

    return Row(
      spacing: AppSpacing.xs,
      children: [
        AppIconButton(
          icon: AppIcons.arrowLeft,
          semanticsLabel: l10n.goBack,
          onPressed: () => Navigator.of(context).pop(),
        ),
        Expanded(
          child: AppTooltip(
            tip: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title),
                AppCopyText(
                  file.path,
                  copiedMessage: l10n.copiedToClipboard,
                  variant: AppTextVariant.caption,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  title,
                  variant: AppTextVariant.item,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                AppText(_meta(l10n), variant: AppTextVariant.meta, maxLines: 1),
              ],
            ),
          ),
        ),
        if (controller?.search != null)
          AppIconButton(
            icon: AppIcons.search,
            semanticsLabel: l10n.pdfMenuSearch,
            onPressed: onSearch,
          ),
        if (controller != null)
          AppIconButton(
            icon: AppIcons.tableOfContents,
            semanticsLabel: l10n.pdfMenuNotes,
            onPressed: onShowNotes,
          ),
        _OverflowMenu(
          items: [
            AppCommandItem(
              label: isFavorite
                  ? l10n.removeFromFavoritesAction
                  : l10n.addToFavoritesAction,
              icon: AppIcons.star,
              onSelect: () =>
                  DocumentCommands.toggleFavorite(context, ref, file),
            ),
            if (controller != null && controller.supportsPagination)
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
                onSelect: onExportNotes,
              ),
          ],
        ),
      ],
    );
  }
}

class _OverflowMenu extends StatelessWidget {
  const _OverflowMenu({required this.items});

  final List<AppCommandItem> items;

  static const _trigger = AppIconButton(
    icon: AppIcons.ellipsisVertical,
    onPressed: null,
    enabled: true,
  );

  @override
  Widget build(BuildContext context) => AppRotation.of(context) != 0
      ? AppIconButton(
          icon: AppIcons.ellipsisVertical,
          onPressed: () =>
              AppCommandSidePanel.show(context: context, items: items),
        )
      : AppPopoverMenu(items: items, child: _trigger);
}
