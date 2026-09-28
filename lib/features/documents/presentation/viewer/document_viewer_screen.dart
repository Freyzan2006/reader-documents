import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';
import 'package:reader_documents/features/documents/application/controllers/document_bookmarks_controller.dart';
import 'package:reader_documents/features/documents/application/controllers/document_highlights_controller.dart';
import 'package:reader_documents/features/documents/application/documents_providers.dart';
import 'package:reader_documents/features/documents/application/controllers/reading_progress_controller.dart';
import 'package:reader_documents/features/documents/data/models/document_file.dart';

import '../actions/document_bookmark_prompt.dart';
import '../actions/document_page_capture.dart';
import 'common/document_bookmarks.dart';
import 'common/document_context_menu_content.dart';
import 'common/document_error_view.dart';
import 'common/document_loading_banner.dart';
import 'common/document_magnifier.dart';
import 'common/document_password_prompt.dart';
import 'common/document_viewer_header_overlay.dart';
import 'common/document_viewer_search_bar.dart';
import 'common/document_viewer_toolbar.dart';
import 'common/document_viewer_zoom_controls.dart';
import 'contract/document_text_selection.dart';
import 'contract/document_viewer_controller.dart';
import 'document_password_controller.dart';
import 'document_viewer_factory.dart';
import 'header_visibility_controller.dart';

class DocumentViewerScreen extends ConsumerStatefulWidget {
  const DocumentViewerScreen({required this.file, super.key});

  final DocumentFile file;

  @override
  ConsumerState<DocumentViewerScreen> createState() =>
      _DocumentViewerScreenState();
}

class _DocumentViewerScreenState extends ConsumerState<DocumentViewerScreen> {
  final _headerVisibility = HeaderVisibilityController();
  late final ReadingProgressController _readingProgress;
  late final DocumentHighlightsController _highlights;
  late final DocumentBookmarksController _bookmarks;
  final _password = DocumentPasswordController();

  final _captureKey = GlobalKey();

  DocumentViewerController? _viewerController;
  bool _searchActive = false;
  int _quarterTurns = 0;
  final _searchController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _highlights = DocumentHighlightsController(
      ref.read(highlightsRepositoryProvider),
      widget.file.path,
    );
    _readingProgress = ReadingProgressController(
      ref.read(readingProgressRepositoryProvider),
      widget.file.path,
    );
    _bookmarks = DocumentBookmarksController(
      ref.read(bookmarksRepositoryProvider),
      widget.file.path,
    );
    _headerVisibility.addListener(_onControllerChanged);
    _readingProgress.addListener(_onControllerChanged);
    _bookmarks.addListener(_onControllerChanged);
    _password.addListener(_onControllerChanged);
    _headerVisibility.scheduleAutoHide();
    _readingProgress.load();
    _highlights.load();
    _bookmarks.load();
  }

  void _onControllerChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _headerVisibility
      ..removeListener(_onControllerChanged)
      ..dispose();
    _readingProgress
      ..removeListener(_onControllerChanged)
      ..dispose();
    _bookmarks
      ..removeListener(_onControllerChanged)
      ..dispose();
    _viewerController?.removeListener(_onControllerChanged);
    _highlights.dispose();
    _password
      ..removeListener(_onControllerChanged)
      ..dispose();
    _searchController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleViewerReady(DocumentViewerController controller) {
    controller.addListener(_onControllerChanged);
    setState(() => _viewerController = controller);
  }

  Future<void> _openSearch() async {
    _headerVisibility.cancelAutoHide();
    setState(() => _searchActive = true);
    await _viewerController?.search?.prepare();
  }

  void _closeSearch() {
    setState(() => _searchActive = false);
    _searchController.clear();
    _viewerController?.search?.resetTextSearch();
    _headerVisibility.scheduleAutoHide();
  }

  void _rotate() => setState(() => _quarterTurns = _quarterTurns == 0 ? 1 : 0);

  Future<void> _captureScreenshot() =>
      DocumentPageCapture.capture(context, _captureKey, widget.file.name);

  Future<void> _toggleBookmark() async {
    final page = _viewerController?.currentPage;
    if (page == null) return;
    final existing = _bookmarks.forPage(page);
    if (existing != null) {
      await _bookmarks.remove(existing.id);
    } else {
      await DocumentBookmarkPrompt.add(
        context: context,
        controller: _bookmarks,
        pageNumber: page,
      );
    }
  }

  void _showBookmarks() {
    final controller = _viewerController;
    if (controller == null) return;
    DocumentBookmarksSheet.show(
      context: context,
      bookmarks: _bookmarks,
      viewerController: controller,
    );
  }

  bool _handleBackgroundTap() {
    if (_searchActive) return false;
    _headerVisibility.toggle();
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

  void _resolvePassword(String? password) {
    _passwordController.clear();
    _password.resolve(password);
  }

  Widget _buildContent(BuildContext context, DocumentFile file) {
    if (!_readingProgress.isReady) return const DocumentLoadingBanner();
    return DocumentViewerFactory.build(
      file: file,
      initialPageNumber:
          _viewerController?.currentPage ?? _readingProgress.initialPage,
      highlights: _highlights,
      onPageChanged: _readingProgress.onPageChanged,
      onReady: _handleViewerReady,
      onBackgroundTap: _handleBackgroundTap,
      passwordProvider: _password.provide,
      buildContextMenu: _buildContextMenu,
      buildMagnifier: (context, content, contentSize) =>
          DocumentMagnifier(content: content, contentSize: contentSize),
      buildErrorBanner:
          (context, {required isPasswordProtected, required onBack}) =>
              DocumentErrorView(
                isPasswordProtected: isPasswordProtected,
                onBack: onBack,
              ),
      buildLoadingBanner: (context) => const DocumentLoadingBanner(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final file = widget.file;
    final title = ref.watch(documentTitleProvider(file.path)) ?? file.name;
    final viewerController = _viewerController;

    return Stack(
      children: [
        Positioned.fill(
          child: RotatedBox(
            quarterTurns: _quarterTurns,
            child: Stack(
              children: [
                Positioned.fill(
                  child: RepaintBoundary(
                    key: _captureKey,
                    child: KeyedSubtree(
                      key: ValueKey(_quarterTurns),
                      child: _buildContent(context, file),
                    ),
                  ),
                ),
                DocumentViewerHeaderOverlay(
                  visible: _headerVisibility.visible,
                  topSafeArea: _quarterTurns == 0,
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
                          onRotate: _rotate,
                          onScreenshot: _captureScreenshot,
                          isBookmarked: viewerController?.currentPage != null
                              ? _bookmarks.isBookmarked(
                                  viewerController!.currentPage!,
                                )
                              : false,
                          onToggleBookmark: _toggleBookmark,
                          onShowBookmarks: _showBookmarks,
                          quarterTurns: _quarterTurns,
                        ),
                ),
                if (!_password.isPrompting)
                  Positioned(
                    right: AppSpacing.lg,
                    bottom: AppSpacing.lg,
                    child: SafeArea(
                      child: AppFade(
                        visible: _headerVisibility.visible,
                        child: DocumentViewerZoomControls(
                          controller: viewerController,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (_password.isPrompting)
          Positioned.fill(
            child: DocumentPasswordPrompt(
              incorrect: _password.incorrect,
              controller: _passwordController,
              onCancel: () => _resolvePassword(null),
              onUnlock: () => _resolvePassword(_passwordController.text),
            ),
          ),
      ],
    );
  }
}
