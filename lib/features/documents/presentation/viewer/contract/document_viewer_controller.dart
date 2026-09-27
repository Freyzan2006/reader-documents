import 'package:flutter/widgets.dart';
import 'package:reader_documents/features/documents/data/models/document_outline_node.dart';

abstract class DocumentSearchSession extends ChangeNotifier {
  bool get isPreparing;
  bool get hasMatches;
  int? get currentIndex;
  int get matchCount;
  Future<void> prepare();
  void startTextSearch(String text);
  void resetTextSearch();
  void goToNextMatch();
  void goToPrevMatch();
}

abstract class DocumentViewerController extends ChangeNotifier {
  int? get currentPage;
  int get pageCount;
  Future<void> goToPage(int pageNumber);
  void invalidate();
  DocumentSearchSession? get search;
  List<DocumentOutlineNode> get outline;
  double get zoom;
  double get minZoom;
  double get maxZoom;
  Future<void> setZoom(double zoom);
  Future<void> zoomIn();
  Future<void> zoomOut();
  Widget buildPageThumbnail(
    BuildContext context,
    int pageNumber, {
    required bool isCurrent,
  });
}
