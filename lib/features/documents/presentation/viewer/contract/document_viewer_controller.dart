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
  /// False for formats with no stable, addressable page numbers (e.g. a
  /// reflowable format rendered as one continuous flow). When false, UI
  /// built on [currentPage]/[pageCount]/[goToPage]/[buildPageThumbnail]
  /// (the page indicator, the minimap, per-page bookmarks) must not be
  /// shown — those members still need an implementation to satisfy the
  /// interface, but callers must not invoke them when this is false.
  bool get supportsPagination;

  int? get currentPage;
  int get pageCount;
  Future<void> goToPage(int pageNumber);
  Widget buildPageThumbnail(
    BuildContext context,
    int pageNumber, {
    required bool isCurrent,
  });

  /// False for formats/viewers with no imperative zoom control (e.g. only
  /// a bare pinch gesture with no exposed controller). When false, UI
  /// built on [zoom]/[minZoom]/[maxZoom]/[setZoom] must not be shown.
  bool get supportsZoom;

  double get zoom;
  double get minZoom;
  double get maxZoom;
  Future<void> setZoom(double zoom);
  Future<void> zoomIn();
  Future<void> zoomOut();

  void invalidate();
  DocumentSearchSession? get search;
  List<DocumentOutlineNode> get outline;
}
