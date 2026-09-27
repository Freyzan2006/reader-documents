import 'dart:async';

import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';
import 'package:reader_documents/features/documents/application/documents_providers.dart';
import 'package:reader_documents/features/documents/data/document_file.dart';
import 'package:reader_documents/features/documents/data/document_highlight.dart';
import 'package:reader_documents/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

import '../ai_providers.dart';
import '../document_rename.dart';
import '../document_sharing.dart';
import '../search_providers.dart';
import '../translate_providers.dart';
import 'document_context_menu.dart';
import 'document_error_view.dart';
import 'document_magnifier.dart';
import 'document_minimap.dart';
import 'document_outline.dart';
import 'document_text_selection.dart';
import 'document_viewer_controller.dart';
import 'pdf/pdf_document_viewer.dart';

class DocumentViewerScreen extends ConsumerStatefulWidget {
  const DocumentViewerScreen({required this.file, super.key});

  final DocumentFile file;

  @override
  ConsumerState<DocumentViewerScreen> createState() =>
      _DocumentViewerScreenState();
}

class _DocumentViewerScreenState extends ConsumerState<DocumentViewerScreen> {
  static const _skeletonPageCount = 3;
  static const _skeletonPageOffset = 10.0;
  static const _autoHideDelay = Duration(seconds: 3);
  static const _visibilityAnimationDuration = Duration(milliseconds: 200);
  static const _saveProgressDebounce = Duration(milliseconds: 400);
  static const _actionIconSize = 18.0;

  bool _headerVisible = true;
  Timer? _autoHideTimer;

  bool _initialPageReady = false;
  int _initialPageNumber = 1;
  int? _pendingPage;
  Timer? _saveProgressTimer;

  DocumentViewerController? _viewerController;

  bool _searchActive = false;
  final _searchController = TextEditingController();

  final _highlights = ValueNotifier<List<DocumentHighlight>>([]);

  int _passwordAttempts = 0;
  bool _passwordIncorrect = false;
  Completer<String?>? _passwordCompleter;
  final _passwordController = TextEditingController();

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
    _highlights.value = highlights ?? [];
  }

  Future<void> _addHighlight(
    DocumentHighlightDraft draft,
    DocumentHighlightColor color,
  ) async {
    final highlight = DocumentHighlight.fromDraft(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      draft: draft,
      color: color,
    );
    _highlights.value = [..._highlights.value, highlight];
    await ref
        .read(highlightsRepositoryProvider)
        .save(widget.file.path, _highlights.value);
  }

  Future<void> _removeHighlight(DocumentHighlight highlight) async {
    _highlights.value = _highlights.value
        .where((h) => h.id != highlight.id)
        .toList();
    await ref
        .read(highlightsRepositoryProvider)
        .save(widget.file.path, _highlights.value);
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
    _viewerController?.removeListener(_onViewerControllerChanged);
    _highlights.dispose();
    _searchController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleViewerReady(DocumentViewerController controller) {
    controller.addListener(_onViewerControllerChanged);
    setState(() => _viewerController = controller);
  }

  void _onViewerControllerChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _openSearch() async {
    _autoHideTimer?.cancel();
    setState(() => _searchActive = true);
    await _viewerController?.search?.prepare();
  }

  void _closeSearch() {
    setState(() => _searchActive = false);
    _searchController.clear();
    _viewerController?.search?.resetTextSearch();
    _scheduleAutoHide();
  }

  Widget _buildSearchBar(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final session = _viewerController?.search;
    final hasMatches = session?.hasMatches ?? false;

    return Row(
      spacing: AppSpacing.sm,
      children: [
        AppIconButton(icon: AppIcons.x, onPressed: _closeSearch),
        Expanded(
          child: AppInput(
            controller: _searchController,
            hint: l10n.pdfSearchHint,
            autofocus: true,
            enabled: !(session?.isPreparing ?? false),
            onChanged: session?.startTextSearch,
          ),
        ),
        if (session?.isPreparing ?? false)
          const AppSpinner(size: AppSpinnerSize.sm),
        if (hasMatches)
          AppBadge(
            variant: AppBadgeVariant.secondary,
            child: Text('${session!.currentIndex! + 1}/${session.matchCount}'),
          ),
        AppIconButton(
          icon: AppIcons.chevronUp,
          onPressed: hasMatches ? session!.goToPrevMatch : null,
        ),
        AppIconButton(
          icon: AppIcons.chevronDown,
          onPressed: hasMatches ? session!.goToNextMatch : null,
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

  bool _handleBackgroundTap() {
    if (_searchActive) return false;
    _toggleHeader();
    return true;
  }

  Widget? _buildContextMenu(
    BuildContext context,
    DocumentTextSelection selection,
    VoidCallback dismiss,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final foreground = AppColors.of(context).foreground;
    final entries = <DocumentContextMenuEntry>[];

    if (selection.isCopyAllowed && selection.hasSelectedText) {
      entries.add(
        DocumentContextMenuAction(
          label: l10n.contextMenuCopy,
          icon: Icon(AppIcons.copy, size: _actionIconSize, color: foreground),
          onPressed: () {
            selection.copyTextSelection();
            dismiss();
          },
        ),
      );
    }

    if (!selection.isSelectingAllText) {
      entries.add(
        DocumentContextMenuAction(
          label: l10n.contextMenuSelectAll,
          icon: Icon(
            AppIcons.textSelect,
            size: _actionIconSize,
            color: foreground,
          ),
          onPressed: selection.selectAllText,
        ),
      );
    }

    if (selection.hasSelectedText) {
      final draft = selection.highlightDraft;
      if (draft != null) {
        DocumentHighlight? existing;
        for (final highlight in _highlights.value) {
          if (highlight.overlapsRange(
            draft.pageNumber,
            draft.startIndex,
            draft.endIndex,
          )) {
            existing = highlight;
            break;
          }
        }

        if (existing != null) {
          final highlight = existing;
          entries.add(
            DocumentContextMenuAction(
              label: l10n.removeHighlight,
              icon: Icon(
                AppIcons.penOff,
                size: _actionIconSize,
                color: foreground,
              ),
              onPressed: () {
                _removeHighlight(highlight);
                dismiss();
              },
            ),
          );
        } else {
          entries.add(
            DocumentContextMenuGroup(
              label: 'Highlight',
              icon: Icon(
                AppIcons.highlighter,
                size: _actionIconSize,
                color: foreground,
              ),
              children: [
                for (final color in DocumentHighlightColor.values)
                  DocumentContextMenuAction(
                    label: color.name,
                    icon: _HighlightSwatch(color: color, size: _actionIconSize),
                    onPressed: () {
                      _addHighlight(draft, color);
                      dismiss();
                    },
                  ),
              ],
            ),
          );
        }
      }

      entries.add(
        DocumentContextMenuGroup(
          label: 'AI',
          icon: Icon(
            AppIcons.sparkles,
            size: _actionIconSize,
            color: foreground,
          ),
          children: [
            for (final provider in AiProviders.all)
              DocumentContextMenuAction(
                label: provider.label,
                icon: AiProviderIcon(provider: provider, size: _actionIconSize),
                onPressed: () => _askProvider(selection, dismiss, provider),
              ),
          ],
        ),
      );

      final languageCode = Localizations.localeOf(context).languageCode;
      entries.add(
        DocumentContextMenuGroup(
          label: 'Translate',
          icon: Icon(
            AppIcons.languages,
            size: _actionIconSize,
            color: foreground,
          ),
          children: [
            for (final provider in TranslateProviders.all)
              DocumentContextMenuAction(
                label: provider.label,
                icon: Icon(
                  provider.icon,
                  size: _actionIconSize,
                  color: provider.color,
                ),
                onPressed: () =>
                    _translateWith(selection, dismiss, provider, languageCode),
              ),
          ],
        ),
      );

      entries.add(
        DocumentContextMenuGroup(
          label: 'Search',
          icon: Icon(AppIcons.search, size: _actionIconSize, color: foreground),
          children: [
            for (final provider in SearchProviders.all)
              DocumentContextMenuAction(
                label: provider.label,
                icon: Icon(
                  provider.icon,
                  size: _actionIconSize,
                  color: provider.color ?? foreground,
                ),
                onPressed: () =>
                    _searchWith(selection, dismiss, provider, languageCode),
              ),
          ],
        ),
      );
    }

    if (entries.isEmpty) return null;
    return DocumentContextMenu(entries: entries);
  }

  Widget _buildMagnifier(
    BuildContext context,
    Widget content,
    Size contentSize,
  ) => DocumentMagnifier(content: content, contentSize: contentSize);

  Future<void> _askProvider(
    DocumentTextSelection selection,
    VoidCallback dismiss,
    AiProvider provider,
  ) async {
    final text = await selection.getSelectedText();
    dismiss();
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
    DocumentTextSelection selection,
    VoidCallback dismiss,
    TranslateProvider provider,
    String targetLanguageCode,
  ) async {
    final text = await selection.getSelectedText();
    dismiss();
    if (text.trim().isEmpty) return;
    await launchUrl(
      provider.buildUri(text, targetLanguageCode),
      mode: LaunchMode.externalApplication,
    );
  }

  Future<void> _searchWith(
    DocumentTextSelection selection,
    VoidCallback dismiss,
    SearchProvider provider,
    String languageCode,
  ) async {
    final text = await selection.getSelectedText();
    dismiss();
    if (text.trim().isEmpty) return;
    await launchUrl(
      provider.buildUri(text, languageCode),
      mode: LaunchMode.externalApplication,
    );
  }

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
    BuildContext context, {
    required bool isPasswordProtected,
    required VoidCallback onBack,
  }) => DocumentErrorView(
    isPasswordProtected: isPasswordProtected,
    onBack: onBack,
  );

  static Widget _buildLoadingBanner(BuildContext context) => Center(
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
    final l10n = AppLocalizations.of(context)!;
    final file = widget.file;
    final title = ref.watch(documentTitleProvider(file.path)) ?? file.name;
    final viewerController = _viewerController;

    return Stack(
      children: [
        Positioned.fill(
          child: !_initialPageReady
              ? _buildLoadingBanner(context)
              : PdfDocumentViewer(
                  file: file,
                  initialPageNumber: _initialPageNumber,
                  highlights: _highlights,
                  onPageChanged: _onPageChanged,
                  onReady: _handleViewerReady,
                  onBackgroundTap: _handleBackgroundTap,
                  passwordProvider: _providePassword,
                  buildContextMenu: _buildContextMenu,
                  buildMagnifier: _buildMagnifier,
                  buildErrorBanner: _buildErrorBanner,
                  buildLoadingBanner: _buildLoadingBanner,
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
                                  child: AppTooltip(
                                    tip: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                onPressed: () => ref
                                    .read(favoritesProvider.notifier)
                                    .toggle(file.path),
                                color: ref.watch(isFavoriteProvider(file.path))
                                    ? AppColors.warning(context)
                                    : null,
                              ),
                              AppPopoverMenu(
                                items: [
                                  AppCommandItem(
                                    label: l10n.pdfMenuRename,
                                    icon: AppIcons.pencil,
                                    onSelect: () => DocumentRename.show(
                                      context: context,
                                      ref: ref,
                                      file: file,
                                    ),
                                  ),
                                  if (viewerController?.search != null)
                                    AppCommandItem(
                                      label: l10n.pdfMenuSearch,
                                      icon: AppIcons.search,
                                      onSelect: _openSearch,
                                    ),
                                  if (viewerController?.outline.isNotEmpty ??
                                      false)
                                    AppCommandItem(
                                      label: l10n.pdfMenuOutline,
                                      icon: AppIcons.tableOfContents,
                                      onSelect: () => DocumentOutlineSheet.show(
                                        context: context,
                                        controller: viewerController!,
                                      ),
                                    ),
                                  if (viewerController != null)
                                    AppCommandItem(
                                      label: l10n.pdfMenuPages,
                                      icon: AppIcons.layoutGrid,
                                      onSelect: () => DocumentMinimapSheet.show(
                                        context: context,
                                        controller: viewerController,
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

  final DocumentHighlightColor color;
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
