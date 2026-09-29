import 'dart:io';

import 'package:docx_file_viewer/docx_file_viewer.dart';
import 'package:flutter/widgets.dart';

import '../common/document_loading_overlay.dart';
import '../contract/document_viewer.dart';
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

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: widget.onBackgroundTap,
      child: Stack(
        children: [
          DocxView(
            file: _file,
            searchController: _searchController,
            onLoaded: _onLoaded,
            onError: _onError,
            config: const DocxViewConfig(pageMode: DocxPageMode.continuous),
          ),
          if (!_loaded)
            DocumentLoadingOverlay(banner: widget.buildLoadingBanner(context)),
        ],
      ),
    );
  }
}
