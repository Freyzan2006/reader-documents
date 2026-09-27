import 'package:flutter/widgets.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';
import 'package:reader_documents/features/documents/data/models/document_outline_node.dart';
import 'package:reader_documents/features/documents/presentation/viewer/contract/document_viewer_controller.dart';

import 'pdf_document_search_session.dart';

class PdfDocumentViewerController extends DocumentViewerController {
  PdfDocumentViewerController(this._raw, this._document) {
    _raw.addListener(notifyListeners);
  }

  static const _thumbnailDpi = 32.0;

  final PdfViewerController _raw;
  final PdfDocument _document;
  PdfDocumentSearchSession? _search;
  List<DocumentOutlineNode> _outline = const [];

  PdfViewerController get rawController => _raw;

  @override
  int? get currentPage => _raw.pageNumber;

  @override
  int get pageCount => _document.pages.length;

  @override
  Future<void> goToPage(int pageNumber) async =>
      _raw.goToPage(pageNumber: pageNumber);

  @override
  void invalidate() => _raw.invalidate();

  @override
  DocumentSearchSession? get search => _search;

  @override
  List<DocumentOutlineNode> get outline => _outline;

  static const _zoomStep = 0.1;

  @override
  double get zoom => _raw.currentZoom;

  @override
  double get minZoom => _raw.minScale;

  @override
  double get maxZoom => _raw.maxScale;

  @override
  Future<void> setZoom(double zoom) => _raw.setZoom(
    _raw.centerPosition,
    zoom.clamp(minZoom, maxZoom).toDouble(),
  );

  @override
  Future<void> zoomIn() => setZoom(zoom + _zoomStep);

  @override
  Future<void> zoomOut() => setZoom(zoom - _zoomStep);

  void attachSearchSession(PdfDocumentSearchSession session) {
    _search = session;
    session.addListener(notifyListeners);
    notifyListeners();
  }

  Future<void> loadOutline() async {
    final outline = await _document.loadOutline();
    _outline = outline.map(_convertOutlineNode).toList();
    notifyListeners();
  }

  static DocumentOutlineNode _convertOutlineNode(PdfOutlineNode node) =>
      DocumentOutlineNode(
        title: node.title,
        pageNumber: node.dest?.pageNumber,
        children: node.children.map(_convertOutlineNode).toList(),
      );

  @override
  Widget buildPageThumbnail(
    BuildContext context,
    int pageNumber, {
    required bool isCurrent,
  }) => PdfPageView(
    document: _document,
    pageNumber: pageNumber,
    maximumDpi: _thumbnailDpi,
    backgroundColor: AppColors.of(context).background,
    decorationBuilder: (context, pageSize, page, pageImage) => AspectRatio(
      aspectRatio: pageSize.width / pageSize.height,
      child:
          pageImage ??
          AppSkeleton(width: pageSize.width, height: pageSize.height),
    ),
  );

  @override
  void dispose() {
    _raw.removeListener(notifyListeners);
    _search?.dispose();
    super.dispose();
  }
}
