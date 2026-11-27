import 'package:flutter/widgets.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';
import 'package:reader_documents/l10n/app_localizations.dart';

import '../contract/document_viewer_controller.dart';
import 'document_page_indicator.dart';

class DocumentViewerBottomBar extends StatelessWidget {
  const DocumentViewerBottomBar({
    required this.controller,
    required this.isBookmarked,
    required this.onToggleBookmark,
    required this.warmFilterEnabled,
    required this.onToggleWarmFilter,
    super.key,
  });

  static const _zoomStep = 0.1;

  final DocumentViewerController? controller;
  final bool isBookmarked;
  final VoidCallback onToggleBookmark;
  final bool warmFilterEnabled;
  final VoidCallback onToggleWarmFilter;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final controller = this.controller;
    final paginated = controller != null && controller.supportsPagination;
    final zoomable = controller != null && controller.supportsZoom;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: AppSpacing.xs,
        children: [
          if (paginated && controller.pageCount > 1)
            DocumentPageScrubber(controller: controller),
          Row(
            children: [
              if (paginated)
                AppIconButton(
                  icon: isBookmarked
                      ? AppIcons.bookmarkCheck
                      : AppIcons.bookmark,
                  semanticsLabel: l10n.addBookmarkTitle,
                  variant: isBookmarked
                      ? AppIconButtonVariant.inverse
                      : AppIconButtonVariant.ghost,
                  onPressed: onToggleBookmark,
                ),
              AppIconButton(
                icon: AppIcons.lamp,
                semanticsLabel: warmFilterEnabled
                    ? l10n.pdfMenuWarmFilterOff
                    : l10n.pdfMenuWarmFilterOn,
                variant: warmFilterEnabled
                    ? AppIconButtonVariant.inverse
                    : AppIconButtonVariant.ghost,
                onPressed: onToggleWarmFilter,
              ),
              Expanded(
                child: Center(
                  child: DocumentPageIndicator(controller: controller),
                ),
              ),
              if (zoomable) ...[
                AppIconButton(
                  icon: AppIcons.minus,
                  semanticsLabel: l10n.zoomOut,
                  onPressed: controller.zoom > controller.minZoom
                      ? () => controller.setZoom(controller.zoom - _zoomStep)
                      : null,
                ),
                AppIconButton(
                  icon: AppIcons.plus,
                  semanticsLabel: l10n.zoomIn,
                  onPressed: controller.zoom < controller.maxZoom
                      ? () => controller.setZoom(controller.zoom + _zoomStep)
                      : null,
                ),
              ] else
                const SizedBox(width: 80),
            ],
          ),
        ],
      ),
    );
  }
}

class DocumentPageScrubber extends StatefulWidget {
  const DocumentPageScrubber({required this.controller, super.key});

  final DocumentViewerController controller;

  @override
  State<DocumentPageScrubber> createState() => _DocumentPageScrubberState();
}

class _DocumentPageScrubberState extends State<DocumentPageScrubber> {
  int? _dragPage;

  int get _lastIndex => widget.controller.pageCount - 1;

  double _fractionOf(int page) => (page - 1) / _lastIndex;

  int _pageOf(double fraction) => (fraction * _lastIndex).round() + 1;

  void _onChanged(double fraction) {
    final page = _pageOf(fraction);
    if (page == _dragPage) return;
    setState(() => _dragPage = page);
    widget.controller.goToPage(page);
  }

  @override
  Widget build(BuildContext context) {
    final page = _dragPage ?? widget.controller.currentPage ?? 1;
    if (_dragPage != null && widget.controller.currentPage == _dragPage) {
      _dragPage = null;
    }
    return AppSlider(
      value: _fractionOf(page),
      semanticsLabel: AppLocalizations.of(context)!.minimapJumpToPageHint,
      onChanged: _onChanged,
    );
  }
}
