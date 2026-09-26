import 'package:flutter/rendering.dart' show ScrollCacheExtent;
import 'package:flutter/widgets.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';
import 'package:reader_documents/l10n/app_localizations.dart';

import 'pdf_error_view.dart';

abstract final class PdfMinimapSheet {
  static Future<void> show({
    required BuildContext context,
    required PdfViewerController controller,
    required String fileFormatLabel,
  }) => AppSheet.show(
    context: context,
    initialSize: 0.6,
    builder: (context, scrollController) => PdfMinimap(
      controller: controller,
      scrollController: scrollController,
      fileFormatLabel: fileFormatLabel,
    ),
  );
}

class PdfMinimap extends StatefulWidget {
  const PdfMinimap({
    required this.controller,
    required this.scrollController,
    required this.fileFormatLabel,
    super.key,
  });

  static const _thumbnailDpi = 32.0;
  static const _crossAxisCount = 3;
  // Flutter's default is 250.0; a smaller buffer means fewer off-screen
  // thumbnails get built/decoded ahead of scroll, trading a bit more pop-in
  // on fast scrolls for lower peak memory on weak devices.
  static const _gridCacheExtent = 100.0;

  final PdfViewerController controller;
  final ScrollController scrollController;
  final String fileFormatLabel;

  @override
  State<PdfMinimap> createState() => _PdfMinimapState();
}

class _PdfMinimapState extends State<PdfMinimap> {
  late final _pageInputController = TextEditingController(
    text: widget.controller.pageNumber?.toString() ?? '',
  );

  @override
  void dispose() {
    _pageInputController.dispose();
    super.dispose();
  }

  void _jumpToPage(int? pageNumber, int totalPages) {
    if (pageNumber == null || pageNumber < 1 || pageNumber > totalPages) return;
    widget.controller.goToPage(pageNumber: pageNumber);
    _pageInputController.clear();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: Listenable.merge([
      widget.controller,
      widget.controller.documentRef.resolveListenable(),
    ]),
    builder: (context, _) {
      final listenable = widget.controller.documentRef.resolveListenable();
      final error = listenable.error;
      if (error != null) {
        return PdfErrorView(
          error: error,
          onBack: () => Navigator.of(context).pop(),
        );
      }

      final document = listenable.document;
      if (document == null) {
        return const Center(child: AppSpinner());
      }

      final l10n = AppLocalizations.of(context)!;
      final currentPage = widget.controller.pageNumber ?? 1;
      final totalPages = document.pages.length;

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
                      if (value != null) {
                        widget.controller.goToPage(pageNumber: value);
                      }
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
                PdfMinimap._gridCacheExtent,
              ),
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.none,
                AppSpacing.md,
                AppSpacing.md,
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: PdfMinimap._crossAxisCount,
                mainAxisSpacing: AppSpacing.sm,
                crossAxisSpacing: AppSpacing.sm,
                childAspectRatio: 0.7,
              ),
              itemCount: totalPages,
              itemBuilder: (context, index) {
                final pageNumber = index + 1;
                return _PdfMinimapTile(
                  document: document,
                  pageNumber: pageNumber,
                  isCurrent: pageNumber == currentPage,
                  onTap: () {
                    widget.controller.goToPage(pageNumber: pageNumber);
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

class _PdfMinimapTile extends StatelessWidget {
  const _PdfMinimapTile({
    required this.document,
    required this.pageNumber,
    required this.isCurrent,
    required this.onTap,
  });

  final PdfDocument document;
  final int pageNumber;
  final bool isCurrent;
  final VoidCallback onTap;

  static Widget _decorationBuilder(
    BuildContext context,
    Size pageSize,
    PdfPage page,
    RawImage? pageImage,
  ) => AspectRatio(
    aspectRatio: pageSize.width / pageSize.height,
    child:
        pageImage ??
        AppSkeleton(width: pageSize.width, height: pageSize.height),
  );

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
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
                child: PdfPageView(
                  document: document,
                  pageNumber: pageNumber,
                  maximumDpi: PdfMinimap._thumbnailDpi,
                  backgroundColor: colors.background,
                  decorationBuilder: _decorationBuilder,
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
