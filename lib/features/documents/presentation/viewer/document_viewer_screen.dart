import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';
import 'package:reader_documents/features/documents/application/document_highlights_controller.dart';
import 'package:reader_documents/features/documents/application/documents_providers.dart';
import 'package:reader_documents/features/documents/data/document_file.dart';

import 'common/document_context_menu_content.dart';
import 'common/document_error_view.dart';
import 'common/document_loading_banner.dart';
import 'common/document_magnifier.dart';
import 'common/document_password_prompt.dart';
import 'common/document_viewer_search_bar.dart';
import 'common/document_viewer_toolbar.dart';
import 'contract/document_text_selection.dart';
import 'contract/document_viewer_controller.dart';
import 'document_viewer_factory.dart';

class DocumentViewerScreen extends ConsumerStatefulWidget {
  const DocumentViewerScreen({required this.file, super.key});

  final DocumentFile file;

  @override
  ConsumerState<DocumentViewerScreen> createState() =>
      _DocumentViewerScreenState();
}

class _DocumentViewerScreenState extends ConsumerState<DocumentViewerScreen> {
  static const _autoHideDelay = Duration(seconds: 3);
  static const _visibilityAnimationDuration = Duration(milliseconds: 200);
  static const _saveProgressDebounce = Duration(milliseconds: 400);

  bool _headerVisible = true;
  Timer? _autoHideTimer;

  bool _initialPageReady = false;
  int _initialPageNumber = 1;
  int? _pendingPage;
  Timer? _saveProgressTimer;

  DocumentViewerController? _viewerController;

  bool _searchActive = false;
  final _searchController = TextEditingController();

  late final DocumentHighlightsController _highlights;

  int _passwordAttempts = 0;
  bool _passwordIncorrect = false;
  Completer<String?>? _passwordCompleter;
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _highlights = DocumentHighlightsController(
      ref.read(highlightsRepositoryProvider),
      widget.file.path,
    );
    _scheduleAutoHide();
    _loadInitialPage();
    _highlights.load();
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
    if (!DocumentContextMenuContent.hasEntries(selection)) return null;
    return DocumentContextMenuContent(
      selection: selection,
      highlights: _highlights,
      dismiss: dismiss,
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

  @override
  Widget build(BuildContext context) {
    final file = widget.file;
    final title = ref.watch(documentTitleProvider(file.path)) ?? file.name;
    final viewerController = _viewerController;

    return Stack(
      children: [
        Positioned.fill(
          child: !_initialPageReady
              ? const DocumentLoadingBanner()
              : DocumentViewerFactory.build(
                  file: file,
                  initialPageNumber: _initialPageNumber,
                  highlights: _highlights,
                  onPageChanged: _onPageChanged,
                  onReady: _handleViewerReady,
                  onBackgroundTap: _handleBackgroundTap,
                  passwordProvider: _providePassword,
                  buildContextMenu: _buildContextMenu,
                  buildMagnifier: (context, content, contentSize) =>
                      DocumentMagnifier(
                        content: content,
                        contentSize: contentSize,
                      ),
                  buildErrorBanner:
                      (
                        context, {
                        required isPasswordProtected,
                        required onBack,
                      }) => DocumentErrorView(
                        isPasswordProtected: isPasswordProtected,
                        onBack: onBack,
                      ),
                  buildLoadingBanner: (context) =>
                      const DocumentLoadingBanner(),
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
                        ? DocumentViewerSearchBar(
                            controller: _searchController,
                            session: viewerController?.search,
                            onClose: _closeSearch,
                          )
                        : DocumentViewerToolbar(
                            file: file,
                            title: title,
                            viewerController: viewerController,
                            onSearch: _openSearch,
                          ),
                  ),
                ),
              ),
            ),
          ),
        ),
        if (_passwordCompleter != null)
          Positioned.fill(
            child: DocumentPasswordPrompt(
              incorrect: _passwordIncorrect,
              controller: _passwordController,
              onCancel: () => _resolvePassword(null),
              onUnlock: () => _resolvePassword(_passwordController.text),
            ),
          ),
      ],
    );
  }
}
