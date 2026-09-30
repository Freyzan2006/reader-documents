import 'dart:io';

import 'package:docx_file_viewer/docx_file_viewer.dart';
import 'package:flutter/gestures.dart' show kLongPressTimeout, kTouchSlop;
import 'package:flutter/material.dart' show SelectionArea;
import 'package:flutter/rendering.dart' show SelectedContent;
import 'package:flutter/widgets.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';

import '../common/document_loading_overlay.dart';
import '../contract/document_viewer.dart';
import 'docx_document_text_selection.dart';
import 'docx_document_viewer_controller.dart';

class DocxDocumentViewer extends DocumentViewer {
  const DocxDocumentViewer({
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

  @override
  State<DocxDocumentViewer> createState() => _DocxDocumentViewerState();
}

class _DocxDocumentViewerState extends State<DocxDocumentViewer> {
  final _searchController = DocxSearchController();
  late final _file = File(widget.file.path);
  DocxDocumentViewerController? _controller;
  Object? _error;
  bool _loaded = false;
  SelectedContent? _selection;
  Offset? _pointerDownPosition;
  Duration? _pointerDownTime;

  @override
  void initState() {
    super.initState();
    final controller = DocxDocumentViewerController(_searchController);
    _controller = controller;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.onReady(controller);
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _onError(Object error) => setState(() => _error = error);

  void _onLoaded() => setState(() => _loaded = true);

  // `SelectionArea` installs its own gesture recognizers (tap-to-clear
  // selection, drag-to-select) that win the gesture arena against an
  // ancestor `GestureDetector.onTap` — unlike pdfrx, which tells us directly
  // whether a tap landed on background vs. content, `SelectionArea` has no
  // equivalent hook. A `Listener` sidesteps this entirely: it gets raw
  // pointer events outside the gesture-arena competition, so this fires
  // alongside whatever `SelectionArea` does with the same pointer, not
  // instead of it. "Tap" is approximated as low movement over a short time,
  // so a drag-to-select or a long-press-to-select doesn't also toggle the
  // header.
  void _onPointerDown(PointerDownEvent event) {
    _pointerDownPosition = event.position;
    _pointerDownTime = event.timeStamp;
  }

  void _onPointerUp(PointerUpEvent event) {
    final startPosition = _pointerDownPosition;
    final startTime = _pointerDownTime;
    _pointerDownPosition = null;
    _pointerDownTime = null;
    if (startPosition == null || startTime == null) return;

    final movedFar = (event.position - startPosition).distance > kTouchSlop;
    final tookLong = (event.timeStamp - startTime) > kLongPressTimeout;
    if (!movedFar && !tookLong) widget.onBackgroundTap();
  }

  @override
  Widget build(BuildContext context) {
    final error = _error;
    if (error != null) {
      return widget.buildErrorBanner(
        context,
        isPasswordProtected: false,
        onBack: () => Navigator.of(context).pop(),
      );
    }

    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: _onPointerDown,
      onPointerUp: _onPointerUp,
      child: Stack(
        children: [
          AppTextSelectionTheme(
            color: AppColors.accent(context).withValues(alpha: 0.35),
            child: SelectionArea(
              onSelectionChanged: (content) => _selection = content,
              contextMenuBuilder: (context, state) {
                final content =
                    widget.buildContextMenu(
                      context,
                      DocxDocumentTextSelection(state, _selection),
                      state.hideToolbar,
                    ) ??
                    const SizedBox.shrink();

                // Without this, the Overlay this menu renders into gives the
                // returned widget tight, full-screen constraints — every
                // built-in Flutter selection toolbar avoids that the same
                // way, by wrapping itself in a `CustomSingleChildLayout`
                // anchored to the selection instead of being sized by its
                // ambient parent.
                final anchors = state.contextMenuAnchors;
                return CustomSingleChildLayout(
                  delegate: TextSelectionToolbarLayoutDelegate(
                    anchorAbove: anchors.primaryAnchor,
                    anchorBelow:
                        anchors.secondaryAnchor ?? anchors.primaryAnchor,
                  ),
                  child: content,
                );
              },
              child: DocxView(
                file: _file,
                searchController: _searchController,
                onLoaded: _onLoaded,
                onError: _onError,
                config: const DocxViewConfig(
                  pageMode: DocxPageMode.continuous,
                ),
              ),
            ),
          ),
          if (!_loaded)
            DocumentLoadingOverlay(banner: widget.buildLoadingBanner(context)),
        ],
      ),
    );
  }
}
