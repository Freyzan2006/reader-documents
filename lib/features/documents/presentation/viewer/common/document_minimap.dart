import 'package:flutter/rendering.dart' show ScrollCacheExtent;
import 'package:flutter/widgets.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';
import 'package:reader_documents/l10n/app_localizations.dart';

import '../contract/document_viewer_controller.dart';

abstract final class DocumentMinimapSheet {
  static Future<void> show({
    required BuildContext context,
    required DocumentViewerController controller,
    required String fileFormatLabel,
  }) => AppSheet.show(
    context: context,
    initialSize: 0.6,
    builder: (context, scrollController) => DocumentMinimap(
      controller: controller,
      scrollController: scrollController,
      fileFormatLabel: fileFormatLabel,
    ),
  );
}

class DocumentMinimap extends StatefulWidget {
  const DocumentMinimap({
    required this.controller,
    required this.scrollController,
    required this.fileFormatLabel,
    super.key,
  });

  static const _crossAxisCount = 3;
  static const _gridCacheExtent = 100.0;

  final DocumentViewerController controller;
  final ScrollController scrollController;
  final String fileFormatLabel;

  @override
  State<DocumentMinimap> createState() => _DocumentMinimapState();
}

class _DocumentMinimapState extends State<DocumentMinimap> {
  late final _pageInputController = TextEditingController(
    text: widget.controller.currentPage?.toString() ?? '',
  );

  @override
  void dispose() {
    _pageInputController.dispose();
    super.dispose();
  }

  void _jumpToPage(int? pageNumber, int totalPages) {
    if (pageNumber == null || pageNumber < 1 || pageNumber > totalPages) return;
    widget.controller.goToPage(pageNumber);
    _pageInputController.clear();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: widget.controller,
    builder: (context, _) {
      final l10n = AppLocalizations.of(context)!;
      final currentPage = widget.controller.currentPage ?? 1;
      final totalPages = widget.controller.pageCount;

      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.none,
              AppSpacing.md,
              AppSpacing.md,
            ),
            child: Row(
              spacing: AppSpacing.sm,
              children: [
                AppBadge(
                  variant: AppBadgeVariant.secondary,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: AppSpacing.xs,
                    children: [
                      Icon(
                        AppIcons.fileText,
                        size: 14,
                        color: AppColors.of(context).secondaryForeground,
                      ),
                      Text('$currentPage/$totalPages'),
                    ],
                  ),
                ),
                AppBadge(
                  variant: AppBadgeVariant.accent,
                  child: Text(widget.fileFormatLabel),
                ),
                Expanded(
                  child: AppNumberInput(
                    controller: _pageInputController,
                    hint: l10n.minimapJumpToPageHint,
                    min: 1,
                    max: totalPages,
                    debounce: const Duration(milliseconds: 400),
                    onChanged: (value) {
                      if (value != null) widget.controller.goToPage(value);
                    },
                    onSubmitted: (value) => _jumpToPage(value, totalPages),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              controller: widget.scrollController,
              scrollCacheExtent: const ScrollCacheExtent.pixels(
                DocumentMinimap._gridCacheExtent,
              ),
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.none,
                AppSpacing.md,
                AppSpacing.md,
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: DocumentMinimap._crossAxisCount,
                mainAxisSpacing: AppSpacing.sm,
                crossAxisSpacing: AppSpacing.sm,
                childAspectRatio: 0.7,
              ),
              itemCount: totalPages,
              itemBuilder: (context, index) {
                final pageNumber = index + 1;
                return _DocumentMinimapTile(
                  controller: widget.controller,
                  pageNumber: pageNumber,
                  isCurrent: pageNumber == currentPage,
                  onTap: () {
                    widget.controller.goToPage(pageNumber);
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),
        ],
      );
    },
  );
}

class _DocumentMinimapTile extends StatelessWidget {
  const _DocumentMinimapTile({
    required this.controller,
    required this.pageNumber,
    required this.isCurrent,
    required this.onTap,
  });

  final DocumentViewerController controller;
  final int pageNumber;
  final bool isCurrent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = AppRadius.of(context).md;

    return AppTappable(
      onPressed: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: radius,
          border: Border.all(
            color: isCurrent
                ? AppColors.accent(context)
                : AppBorders.color(context),
            width: isCurrent ? AppBorderWidth.thick : AppBorderWidth.thin,
          ),
        ),
        child: ClipRRect(
          borderRadius: radius,
          child: Stack(
            children: [
              Positioned.fill(
                child: controller.buildPageThumbnail(
                  context,
                  pageNumber,
                  isCurrent: isCurrent,
                ),
              ),
              Positioned(
                right: AppSpacing.xs,
                bottom: AppSpacing.xs,
                child: AppBadge(
                  variant: AppBadgeVariant.secondary,
                  child: Text('$pageNumber'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
