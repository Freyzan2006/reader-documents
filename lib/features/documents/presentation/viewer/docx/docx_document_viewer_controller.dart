import 'package:docx_file_viewer/docx_file_viewer.dart';
import 'package:flutter/widgets.dart';
import 'package:reader_documents/features/documents/data/models/document_outline_node.dart';
import 'package:reader_documents/features/documents/presentation/viewer/contract/document_viewer_controller.dart';

import 'docx_document_search_session.dart';

class DocxDocumentViewerController extends DocumentViewerController {
  DocxDocumentViewerController(DocxSearchController rawSearchController) {
    _search = DocxDocumentSearchSession(rawSearchController)
      ..addListener(notifyListeners);
  }

  late final DocxDocumentSearchSession _search;

  double _readProgress = 0;
  int _reportedPercent = 0;

  /// Scroll position as a fraction of the scrollable extent.
  @override
  double get readProgress => _readProgress;

  /// Records a new reading position.
  ///
  /// Listeners are notified only when the whole-percent readout changes: this
  /// is called on every scroll frame, and rebuilding the indicator that often
  /// would cost more than the readout is worth.
  void setReadProgress(double fraction) {
    _readProgress = fraction;
    final percent = (fraction * 100).round();
    if (percent == _reportedPercent) return;
    _reportedPercent = percent;
    notifyListeners();
  }

  @override
  bool get supportsPagination => false;

  @override
  bool get supportsZoom => false;

  @override
  int? get currentPage => null;

  @override
  int get pageCount => 1;

  @override
  Future<void> goToPage(int pageNumber) async {}

  @override
  Widget buildPageThumbnail(
    BuildContext context,
    int pageNumber, {
    required bool isCurrent,
  }) => const SizedBox.shrink();

  @override
  double get zoom => 1;

  @override
  double get minZoom => 1;

  @override
  double get maxZoom => 1;

  @override
  Future<void> setZoom(double zoom) async {}

  @override
  Future<void> zoomIn() async {}

  @override
  Future<void> zoomOut() async {}

  @override
  void invalidate() {}

  @override
  DocumentSearchSession? get search => _search;

  @override
  List<DocumentOutlineNode> get outline => const [];

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }
}
