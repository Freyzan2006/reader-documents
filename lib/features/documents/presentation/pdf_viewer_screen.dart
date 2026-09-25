import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';
import 'package:reader_documents/features/documents/application/documents_providers.dart';
import 'package:reader_documents/features/documents/data/document_file.dart';
import 'package:reader_documents/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

import 'ai_providers.dart';
import 'pdf_context_menu.dart';
import 'pdf_error_view.dart';
import 'pdf_magnifier.dart';

class PdfViewerScreen extends ConsumerStatefulWidget {
  const PdfViewerScreen({required this.file, super.key});

  final DocumentFile file;

  @override
  ConsumerState<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends ConsumerState<PdfViewerScreen> {
  static const _skeletonPageCount = 3;
  static const _skeletonPageOffset = 10.0;
  static const _autoHideDelay = Duration(seconds: 3);
  static const _visibilityAnimationDuration = Duration(milliseconds: 200);
  static const _saveProgressDebounce = Duration(milliseconds: 400);

  bool _headerVisible = true;
  Timer? _autoHideTimer;

  bool _initialPageReady = false;
  int _initialPageNumber = 1;
  int? _pendingPage;
  Timer? _saveProgressTimer;

  @override
  void initState() {
    super.initState();
    _scheduleAutoHide();
    _loadInitialPage();
  }

  Future<void> _loadInitialPage() async {
    final page = await ref
        .read(readingProgressRepositoryProvider)
        .loadPage(widget.file.path);
    if (!mounted) return;
    setState(() {
      _initialPageNumber = page ?? 1;
      _initialPageReady = true;
    });
  }

  void _onPageChanged(int? pageNumber) {
    if (pageNumber == null) return;
    _pendingPage = pageNumber;
    _saveProgressTimer?.cancel();
    _saveProgressTimer = Timer(_saveProgressDebounce, _flushPendingPage);
  }

  void _flushPendingPage() {
    final page = _pendingPage;
    if (page == null) return;
    _pendingPage = null;
    ref
        .read(readingProgressRepositoryProvider)
        .savePage(widget.file.path, page);
  }

  @override
  void dispose() {
    _autoHideTimer?.cancel();
    _saveProgressTimer?.cancel();
    _flushPendingPage();
    super.dispose();
  }

  void _scheduleAutoHide() {
    _autoHideTimer?.cancel();
    _autoHideTimer = Timer(_autoHideDelay, () {
      if (mounted) setState(() => _headerVisible = false);
    });
  }

  void _toggleHeader() {
    setState(() => _headerVisible = !_headerVisible);
    if (_headerVisible) {
      _scheduleAutoHide();
    } else {
      _autoHideTimer?.cancel();
    }
  }

  bool _onGeneralTap(
    BuildContext context,
    PdfViewerController controller,
    PdfViewerGeneralTapHandlerDetails details,
  ) {
    if (details.type == PdfViewerGeneralTapType.tap &&
        details.tapOn == PdfViewerPart.background) {
      _toggleHeader();
      return true;
    }
    return false;
  }

  static const _actionIconSize = 18.0;

  Widget? _buildContextMenu(
    BuildContext context,
    PdfViewerContextMenuBuilderParams params,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final foreground = AppColors.of(context).foreground;
    final delegate = params.textSelectionDelegate;
    final actions = <PdfContextMenuAction>[];

    if (delegate.isCopyAllowed && delegate.hasSelectedText) {
      actions.add(
        PdfContextMenuAction(
          label: l10n.contextMenuCopy,
          icon: Icon(AppIcons.copy, size: _actionIconSize, color: foreground),
          onPressed: () {
            delegate.copyTextSelection();
            params.dismissContextMenu();
          },
        ),
      );
    }

    if (!delegate.isSelectingAllText) {
      actions.add(
        PdfContextMenuAction(
          label: l10n.contextMenuSelectAll,
          icon: Icon(
            AppIcons.textSelect,
            size: _actionIconSize,
            color: foreground,
          ),
          onPressed: delegate.selectAllText,
        ),
      );
    }

    if (delegate.hasSelectedText) {
      for (final provider in AiProviders.all) {
        actions.add(
          PdfContextMenuAction(
            label: provider.label,
            icon: AiProviderIcon(provider: provider, size: _actionIconSize),
            onPressed: () => _askProvider(params, provider),
          ),
        );
      }
    }

    if (actions.isEmpty) return null;
    return PdfContextMenu(actions: actions);
  }

  Widget? _buildMagnifier(
    BuildContext context,
    PdfTextSelectionAnchor textAnchor,
    PdfViewerSelectionMagnifierParams params,
    Widget magnifierContent,
    Size magnifierContentSize,
    Offset pointerPosition,
    Offset magnifierPosition,
  ) => PdfMagnifier(
    content: magnifierContent,
    contentSize: magnifierContentSize,
  );

  Future<void> _askProvider(
    PdfViewerContextMenuBuilderParams params,
    AiProvider provider,
  ) async {
    final text = await params.textSelectionDelegate.getSelectedText();
    params.dismissContextMenu();
    if (text.trim().isEmpty) return;
    await launchUrl(
      provider.buildUri(text),
      mode: LaunchMode.externalApplication,
    );
  }

  Widget _buildErrorBanner(
    BuildContext context,
    Object error,
    StackTrace? stackTrace,
    PdfDocumentRef documentRef,
  ) => PdfErrorView(error: error, onBack: () => Navigator.of(context).pop());

  static Widget _buildLoadingBanner(
    BuildContext context,
    int bytesDownloaded,
    int? totalBytes,
  ) => Center(
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: AspectRatio(
        aspectRatio: 1 / 1.4,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maxOffset = _skeletonPageOffset * (_skeletonPageCount - 1);
            final pageWidth = constraints.maxWidth - maxOffset;
            final pageHeight = constraints.maxHeight - maxOffset;

            return Stack(
              children: [
                for (var i = 0; i < _skeletonPageCount; i++)
                  Positioned(
                    left: i * _skeletonPageOffset,
                    top: i * _skeletonPageOffset,
                    width: pageWidth,
                    height: pageHeight,
                    child: AppSkeleton(width: pageWidth, height: pageHeight),
                  ),
              ],
            );
          },
        ),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final file = widget.file;

    return Stack(
      children: [
        Positioned.fill(
          child: !_initialPageReady
              ? _buildLoadingBanner(context, 0, null)
              : AppTextSelectionTheme(
                  color: colors.primary.withValues(alpha: 0.35),
                  child: PdfViewer.file(
                    file.path,
                    initialPageNumber: _initialPageNumber,
                    params: PdfViewerParams(
                      backgroundColor: colors.background,
                      sizeDelegateProvider:
                          const PdfViewerSizeDelegateProviderLegacy(
                            useAlternativeFitScaleAsMinScale: false,
                          ),
                      behaviorControlParams:
                          const PdfViewerBehaviorControlParams(
                            loadPageDimensionsOnDemand: true,
                          ),
                      loadingBannerBuilder: _buildLoadingBanner,
                      errorBannerBuilder: _buildErrorBanner,
                      onGeneralTap: _onGeneralTap,
                      onPageChanged: _onPageChanged,
                      buildContextMenu: _buildContextMenu,
                      textSelectionParams: PdfTextSelectionParams(
                        magnifier: PdfViewerSelectionMagnifierParams(
                          builder: _buildMagnifier,
                        ),
                      ),
                    ),
                  ),
                ),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: IgnorePointer(
            ignoring: !_headerVisible,
            child: AnimatedOpacity(
              duration: _visibilityAnimationDuration,
              opacity: _headerVisible ? 1 : 0,
              child: SafeArea(
                bottom: false,
                child: SizedBox(
                  height: AppHeader.height,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                    ),
                    child: Row(
                      spacing: AppSpacing.md,
                      children: [
                        AppIconButton(
                          icon: AppIcons.arrowLeft,
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        Expanded(
                          child: Center(
                            child: AppCard(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.md,
                                vertical: AppSpacing.xs,
                              ),
                              child: AppText(
                                file.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ),
                        AppBadge(
                          variant: AppBadgeVariant.secondary,
                          child: Text(file.type.label),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
