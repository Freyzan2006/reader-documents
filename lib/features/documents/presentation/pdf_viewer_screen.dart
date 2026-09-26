import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';
import 'package:reader_documents/features/documents/application/documents_providers.dart';
import 'package:reader_documents/features/documents/data/document_file.dart';
import 'package:reader_documents/features/documents/data/pdf_highlight.dart';
import 'package:reader_documents/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

import 'ai_providers.dart';
import 'document_sharing.dart';
import 'pdf_context_menu.dart';
import 'pdf_error_view.dart';
import 'pdf_magnifier.dart';
import 'pdf_minimap.dart';
import 'search_providers.dart';
import 'translate_providers.dart';

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

  // Trimmed down from pdfrx's defaults (100 MB cache, 1.0 extent) to keep
  // peak memory lower on weak devices, at the cost of more re-rendering when
  // scrolling back over already-visited pages.
  static const _maxImageBytesCachedOnMemory = 40 * 1024 * 1024;
  static const _pageCacheExtent = 0.5;

  bool _headerVisible = true;
  Timer? _autoHideTimer;

  bool _initialPageReady = false;
  int _initialPageNumber = 1;
  int? _pendingPage;
  Timer? _saveProgressTimer;
  final _pdfController = PdfViewerController();

  PdfTextSearcher? _searcher;
  List<PdfViewerPagePaintCallback>? _pagePaintCallbacks;
  bool _searchActive = false;
  bool _preparingSearch = false;
  bool _pagesFullyMeasured = false;
  final _searchController = TextEditingController();

  List<PdfHighlight> _highlights = [];

  @override
  void initState() {
    super.initState();
    _scheduleAutoHide();
    _loadInitialPage();
    _loadHighlights();
  }

  Future<void> _loadHighlights() async {
    final highlights = await ref
        .read(highlightsRepositoryProvider)
        .load(widget.file.path);
    if (!mounted) return;
    setState(() {
      _highlights = highlights;
      _rebuildPaintCallbacks();
    });
  }

  void _rebuildPaintCallbacks() {
    _pagePaintCallbacks = [
      _paintHighlights,
      if (_searcher != null) _searcher!.pageTextMatchPaintCallback,
    ];
  }

  void _paintHighlights(Canvas canvas, Rect pageRect, PdfPage page) {
    for (final highlight in _highlights) {
      if (highlight.pageNumber != page.pageNumber) continue;
      final paint = Paint()
        ..color = highlight.color.value.withValues(alpha: 0.4);
      for (final rect in highlight.rects) {
        final screenRect = rect
            .toRect(page: page, scaledPageSize: pageRect.size)
            .translate(pageRect.left, pageRect.top);
        canvas.drawRect(screenRect, paint);
      }
    }
  }

  Future<void> _addHighlight(
    PdfPageText pageText,
    int start,
    int end,
    PdfHighlightColor color,
  ) async {
    final highlight = PdfHighlight.fromSelection(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      pageText: pageText,
      startIndex: start,
      endIndex: end,
      color: color,
    );
    setState(() => _highlights = [..._highlights, highlight]);
    _pdfController.invalidate();
    await ref
        .read(highlightsRepositoryProvider)
        .save(widget.file.path, _highlights);
  }

  Future<void> _removeHighlight(PdfHighlight highlight) async {
    setState(
      () =>
          _highlights = _highlights.where((h) => h.id != highlight.id).toList(),
    );
    _pdfController.invalidate();
    await ref
        .read(highlightsRepositoryProvider)
        .save(widget.file.path, _highlights);
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
    _searcher?.dispose();
    _searchController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onViewerReady(PdfDocument document, PdfViewerController controller) {
    final searcher = PdfTextSearcher(controller)..addListener(_onSearchChanged);
    setState(() {
      _searcher = searcher;
      _rebuildPaintCallbacks();
    });
  }

  void _onSearchChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _openSearch() async {
    _autoHideTimer?.cancel();
    setState(() => _searchActive = true);
    if (_pagesFullyMeasured) return;

    // With loadPageDimensionsOnDemand, pages outside the viewport are never
    // measured, and PdfPage.loadText (which PdfTextSearcher relies on)
    // returns nothing for an unmeasured page. Force-measure the whole
    // document once, only when the user actually opens search, so cold
    // start stays lazy but search still covers every page.
    setState(() => _preparingSearch = true);
    await _pdfController.useDocument((document) => document.reloadPages());
    if (!mounted) return;
    setState(() {
      _pagesFullyMeasured = true;
      _preparingSearch = false;
    });
  }

  void _closeSearch() {
    setState(() => _searchActive = false);
    _searchController.clear();
    _searcher?.resetTextSearch();
    _scheduleAutoHide();
  }

  Widget _buildSearchBar(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final searcher = _searcher;
    final hasMatches = searcher?.hasMatches ?? false;

    return Row(
      spacing: AppSpacing.sm,
      children: [
        AppIconButton(icon: AppIcons.x, onPressed: _closeSearch),
        Expanded(
          child: AppInput(
            controller: _searchController,
            hint: l10n.pdfSearchHint,
            autofocus: true,
            enabled: !_preparingSearch,
            onChanged: searcher?.startTextSearch,
          ),
        ),
        if (_preparingSearch) const AppSpinner(size: AppSpinnerSize.sm),
        if (hasMatches)
          AppBadge(
            variant: AppBadgeVariant.secondary,
            child: Text(
              '${searcher!.currentIndex! + 1}/${searcher.matches.length}',
            ),
          ),
        AppIconButton(
          icon: AppIcons.chevronUp,
          onPressed: hasMatches ? searcher!.goToPrevMatch : null,
        ),
        AppIconButton(
          icon: AppIcons.chevronDown,
          onPressed: hasMatches ? searcher!.goToNextMatch : null,
        ),
      ],
    );
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
      if (_searchActive) return false;
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
    final entries = <PdfContextMenuEntry>[];

    if (delegate.isCopyAllowed && delegate.hasSelectedText) {
      entries.add(
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
      entries.add(
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
      final anchorA = params.a;
      final anchorB = params.b;
      if (anchorA != null &&
          anchorB != null &&
          anchorA.page.pageNumber == anchorB.page.pageNumber) {
        final pageNumber = anchorA.page.pageNumber;
        final start = math.min(anchorA.index, anchorB.index);
        final end = math.max(anchorA.index, anchorB.index) + 1;

        PdfHighlight? existing;
        for (final highlight in _highlights) {
          if (highlight.overlapsRange(pageNumber, start, end)) {
            existing = highlight;
            break;
          }
        }

        if (existing != null) {
          final highlight = existing;
          entries.add(
            PdfContextMenuAction(
              label: l10n.removeHighlight,
              icon: Icon(
                AppIcons.penOff,
                size: _actionIconSize,
                color: foreground,
              ),
              onPressed: () {
                _removeHighlight(highlight);
                params.dismissContextMenu();
              },
            ),
          );
        } else {
          entries.add(
            PdfContextMenuGroup(
              label: 'Highlight',
              icon: Icon(
                AppIcons.highlighter,
                size: _actionIconSize,
                color: foreground,
              ),
              children: [
                for (final color in PdfHighlightColor.values)
                  PdfContextMenuAction(
                    label: color.name,
                    icon: _HighlightSwatch(color: color, size: _actionIconSize),
                    onPressed: () {
                      _addHighlight(anchorA.page, start, end, color);
                      params.dismissContextMenu();
                    },
                  ),
              ],
            ),
          );
        }
      }

      entries.add(
        PdfContextMenuGroup(
          label: 'AI',
          icon: Icon(
            AppIcons.sparkles,
            size: _actionIconSize,
            color: foreground,
          ),
          children: [
            for (final provider in AiProviders.all)
              PdfContextMenuAction(
                label: provider.label,
                icon: AiProviderIcon(provider: provider, size: _actionIconSize),
                onPressed: () => _askProvider(params, provider),
              ),
          ],
        ),
      );

      final languageCode = Localizations.localeOf(context).languageCode;
      entries.add(
        PdfContextMenuGroup(
          label: 'Translate',
          icon: Icon(
            AppIcons.languages,
            size: _actionIconSize,
            color: foreground,
          ),
          children: [
            for (final provider in TranslateProviders.all)
              PdfContextMenuAction(
                label: provider.label,
                icon: Icon(
                  provider.icon,
                  size: _actionIconSize,
                  color: provider.color,
                ),
                onPressed: () => _translateWith(params, provider, languageCode),
              ),
          ],
        ),
      );

      entries.add(
        PdfContextMenuGroup(
          label: 'Search',
          icon: Icon(AppIcons.search, size: _actionIconSize, color: foreground),
          children: [
            for (final provider in SearchProviders.all)
              PdfContextMenuAction(
                label: provider.label,
                icon: Icon(
                  provider.icon,
                  size: _actionIconSize,
                  color: provider.color ?? foreground,
                ),
                onPressed: () => _searchWith(params, provider, languageCode),
              ),
          ],
        ),
      );
    }

    if (entries.isEmpty) return null;
    return PdfContextMenu(entries: entries);
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

    if (!provider.prefillsText) {
      await Clipboard.setData(ClipboardData(text: text));
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      AppToast.show(
        context: context,
        title: Text(l10n.aiTextCopiedTitle),
        description: Text(l10n.aiTextCopiedDescription(provider.label)),
      );
    }

    await launchUrl(
      provider.buildUri(text),
      mode: LaunchMode.externalApplication,
    );
  }

  Future<void> _translateWith(
    PdfViewerContextMenuBuilderParams params,
    TranslateProvider provider,
    String targetLanguageCode,
  ) async {
    final text = await params.textSelectionDelegate.getSelectedText();
    params.dismissContextMenu();
    if (text.trim().isEmpty) return;
    await launchUrl(
      provider.buildUri(text, targetLanguageCode),
      mode: LaunchMode.externalApplication,
    );
  }

  Future<void> _searchWith(
    PdfViewerContextMenuBuilderParams params,
    SearchProvider provider,
    String languageCode,
  ) async {
    final text = await params.textSelectionDelegate.getSelectedText();
    params.dismissContextMenu();
    if (text.trim().isEmpty) return;
    await launchUrl(
      provider.buildUri(text, languageCode),
      mode: LaunchMode.externalApplication,
    );
  }

  int _passwordAttempts = 0;
  bool _passwordIncorrect = false;
  Completer<String?>? _passwordCompleter;
  final _passwordController = TextEditingController();

  // pdfrx calls this from its own native-load retry loop on every wrong
  // password, not from a user gesture, so pushing a Navigator route here
  // raced that loop badly (duplicate GlobalKeys, disposed controllers).
  // Resolving a Completer that gates a plain in-tree overlay avoids the
  // Navigator entirely.
  Future<String?> _providePassword() {
    final isRetry = _passwordAttempts > 0;
    _passwordAttempts++;
    final completer = Completer<String?>();
    _passwordCompleter = completer;
    if (mounted) setState(() => _passwordIncorrect = isRetry);
    return completer.future;
  }

  void _resolvePassword(String? password) {
    final completer = _passwordCompleter;
    if (completer == null || completer.isCompleted) return;
    _passwordController.clear();
    setState(() => _passwordCompleter = null);
    completer.complete(password);
  }

  Widget _buildPasswordPrompt(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = AppColors.of(context);

    return ColoredBox(
      color: colors.background,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: AppSpacing.md,
            children: [
              Icon(AppIcons.lock, size: 40, color: colors.mutedForeground),
              AppText(l10n.pdfPasswordTitle, textAlign: TextAlign.center),
              if (_passwordIncorrect)
                AppText(
                  l10n.pdfPasswordIncorrect,
                  variant: AppTextVariant.caption,
                  color: colors.destructive,
                  textAlign: TextAlign.center,
                ),
              AppInput(
                controller: _passwordController,
                hint: l10n.pdfPasswordHint,
                obscureText: true,
                autofocus: true,
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                spacing: AppSpacing.sm,
                children: [
                  AppButton(
                    variant: AppButtonVariant.ghost,
                    onPressed: () => _resolvePassword(null),
                    child: Text(l10n.cancel),
                  ),
                  AppButton(
                    onPressed: () => _resolvePassword(_passwordController.text),
                    child: Text(l10n.pdfPasswordUnlock),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
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
                  color: AppColors.accent(context).withValues(alpha: 0.35),
                  child: PdfViewer.file(
                    file.path,
                    initialPageNumber: _initialPageNumber,
                    controller: _pdfController,
                    passwordProvider: _providePassword,
                    params: PdfViewerParams(
                      backgroundColor: colors.background,
                      maxImageBytesCachedOnMemory: _maxImageBytesCachedOnMemory,
                      horizontalCacheExtent: _pageCacheExtent,
                      verticalCacheExtent: _pageCacheExtent,
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
                      onViewerReady: _onViewerReady,
                      buildContextMenu: _buildContextMenu,
                      pagePaintCallbacks: _pagePaintCallbacks,
                      matchTextColor: AppColors.accent(context)
                          .withValues(alpha: 0.35),
                      activeMatchTextColor: AppColors.accent(context)
                          .withValues(alpha: 0.65),
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
                    child: _searchActive
                        ? _buildSearchBar(context)
                        : Row(
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
                              AppIconButton(
                                icon: AppIcons.search,
                                onPressed: _searcher == null
                                    ? null
                                    : _openSearch,
                              ),
                              AppIconButton(
                                icon: AppIcons.layoutGrid,
                                onPressed: () => PdfMinimapSheet.show(
                                  context: context,
                                  controller: _pdfController,
                                  fileFormatLabel: file.type.label,
                                ),
                              ),
                              AppIconButton(
                                icon: AppIcons.share2,
                                onPressed: () => DocumentSharing.share(file),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ),
          ),
        ),
        if (_passwordCompleter != null)
          Positioned.fill(child: _buildPasswordPrompt(context)),
      ],
    );
  }
}

class _HighlightSwatch extends StatelessWidget {
  const _HighlightSwatch({required this.color, required this.size});

  final PdfHighlightColor color;
  final double size;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: size,
    height: size,
    child: DecoratedBox(
      decoration: BoxDecoration(color: color.value, shape: BoxShape.circle),
    ),
  );
}
