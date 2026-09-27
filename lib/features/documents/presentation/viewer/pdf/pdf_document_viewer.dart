import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';
import 'package:reader_documents/features/documents/data/models/document_highlight.dart';

import '../contract/document_viewer.dart';
import 'pdf_document_search_session.dart';
import 'pdf_document_text_selection.dart';
import 'pdf_document_viewer_controller.dart';
import 'pdf_rect_mapping.dart';

class PdfDocumentViewer extends DocumentViewer {
  const PdfDocumentViewer({
    required super.file,
    required super.initialPageNumber,
    required super.highlights,
    required super.onPageChanged,
    required super.onReady,
    required super.onBackgroundTap,
    required super.passwordProvider,
    required super.buildContextMenu,
    required super.buildMagnifier,
    required super.buildErrorBanner,
    required super.buildLoadingBanner,
    super.key,
  });

  static const _maxImageBytesCachedOnMemory = 40 * 1024 * 1024;
  static const _pageCacheExtent = 0.5;

  @override
  State<PdfDocumentViewer> createState() => _PdfDocumentViewerState();
}

class _PdfDocumentViewerState extends State<PdfDocumentViewer> {
  final _rawController = PdfViewerController();
  PdfDocumentViewerController? _controller;
  List<PdfViewerPagePaintCallback>? _pagePaintCallbacks;

  @override
  void initState() {
    super.initState();
    widget.highlights.addListener(_onHighlightsChanged);
  }

  @override
  void dispose() {
    widget.highlights.removeListener(_onHighlightsChanged);
    _controller?.dispose();
    super.dispose();
  }

  void _onHighlightsChanged() {
    _rebuildPaintCallbacks();
    _rawController.invalidate();
  }

  void _rebuildPaintCallbacks() {
    final searcher = _controller?.search as PdfDocumentSearchSession?;
    setState(() {
      _pagePaintCallbacks = [
        _paintHighlights,
        if (searcher != null) searcher.rawSearcher.pageTextMatchPaintCallback,
      ];
    });
  }

  void _paintHighlights(Canvas canvas, Rect pageRect, PdfPage page) {
    for (final highlight in widget.highlights.value) {
      if (highlight.pageNumber != page.pageNumber) continue;
      final paint = Paint()
        ..color = highlight.color.value.withValues(alpha: 0.4);
      for (final rect in highlight.rects) {
        final screenRect = rect
            .toPdfRect()
            .toRect(page: page, scaledPageSize: pageRect.size)
            .translate(pageRect.left, pageRect.top);
        canvas.drawRect(screenRect, paint);
      }
    }
  }

  Future<void> _onViewerReady(
    PdfDocument document,
    PdfViewerController controller,
  ) async {
    final viewerController = PdfDocumentViewerController(controller, document);
    _controller = viewerController;
    _rebuildPaintCallbacks();
    widget.onReady(viewerController);

    unawaited(viewerController.loadOutline());

    final searcher = PdfTextSearcher(controller);
    final session = PdfDocumentSearchSession(searcher, controller);
    searcher.addListener(_rebuildPaintCallbacks);
    viewerController.attachSearchSession(session);
  }

  bool _onGeneralTap(
    BuildContext context,
    PdfViewerController controller,
    PdfViewerGeneralTapHandlerDetails details,
  ) {
    if (details.type == PdfViewerGeneralTapType.tap &&
        details.tapOn == PdfViewerPart.background) {
      return widget.onBackgroundTap();
    }
    return false;
  }

  Widget? _buildContextMenu(
    BuildContext context,
    PdfViewerContextMenuBuilderParams params,
  ) => widget.buildContextMenu(
    context,
    PdfDocumentTextSelection(params),
    params.dismissContextMenu,
  );

  Widget? _buildMagnifier(
    BuildContext context,
    PdfTextSelectionAnchor textAnchor,
    PdfViewerSelectionMagnifierParams params,
    Widget magnifierContent,
    Size magnifierContentSize,
    Offset pointerPosition,
    Offset magnifierPosition,
  ) => widget.buildMagnifier(context, magnifierContent, magnifierContentSize);

  Widget _buildErrorBanner(
    BuildContext context,
    Object error,
    StackTrace? stackTrace,
    PdfDocumentRef documentRef,
  ) => widget.buildErrorBanner(
    context,
    isPasswordProtected: error is PdfPasswordException,
    onBack: () => Navigator.of(context).pop(),
  );

  Widget _buildLoadingBanner(
    BuildContext context,
    int bytesDownloaded,
    int? totalBytes,
  ) => widget.buildLoadingBanner(context);

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return AppTextSelectionTheme(
      color: AppColors.accent(context).withValues(alpha: 0.35),
      child: PdfViewer.file(
        widget.file.path,
        initialPageNumber: widget.initialPageNumber,
        controller: _rawController,
        passwordProvider: widget.passwordProvider,
        params: PdfViewerParams(
          backgroundColor: colors.background,
          maxImageBytesCachedOnMemory:
              PdfDocumentViewer._maxImageBytesCachedOnMemory,
          horizontalCacheExtent: PdfDocumentViewer._pageCacheExtent,
          verticalCacheExtent: PdfDocumentViewer._pageCacheExtent,
          sizeDelegateProvider: const PdfViewerSizeDelegateProviderLegacy(
            useAlternativeFitScaleAsMinScale: false,
          ),
          behaviorControlParams: const PdfViewerBehaviorControlParams(
            loadPageDimensionsOnDemand: true,
          ),
          loadingBannerBuilder: _buildLoadingBanner,
          errorBannerBuilder: _buildErrorBanner,
          onGeneralTap: _onGeneralTap,
          onPageChanged: widget.onPageChanged,
          onViewerReady: _onViewerReady,
          buildContextMenu: _buildContextMenu,
          pagePaintCallbacks: _pagePaintCallbacks,
          matchTextColor: AppColors.accent(context).withValues(alpha: 0.35),
          activeMatchTextColor: AppColors.accent(context)
              .withValues(alpha: 0.65),
          textSelectionParams: PdfTextSelectionParams(
            magnifier: PdfViewerSelectionMagnifierParams(
              builder: _buildMagnifier,
            ),
          ),
        ),
      ),
    );
  }
}
