import 'package:pdfrx/pdfrx.dart';
import 'package:reader_documents/features/documents/presentation/viewer/document_viewer_controller.dart';

class PdfDocumentSearchSession extends DocumentSearchSession {
  PdfDocumentSearchSession(this._searcher, this._rawController) {
    _searcher.addListener(notifyListeners);
  }

  final PdfTextSearcher _searcher;
  final PdfViewerController _rawController;
  bool _isPreparing = false;
  bool _prepared = false;

  PdfTextSearcher get rawSearcher => _searcher;

  @override
  bool get isPreparing => _isPreparing;

  @override
  bool get hasMatches => _searcher.hasMatches;

  @override
  int? get currentIndex => _searcher.currentIndex;

  @override
  int get matchCount => _searcher.matches.length;

  @override
  Future<void> prepare() async {
    if (_prepared) return;
    _isPreparing = true;
    notifyListeners();
    await _rawController.useDocument((document) => document.reloadPages());
    _prepared = true;
    _isPreparing = false;
    notifyListeners();
  }

  @override
  void startTextSearch(String text) => _searcher.startTextSearch(text);

  @override
  void resetTextSearch() => _searcher.resetTextSearch();

  @override
  void goToNextMatch() => _searcher.goToNextMatch();

  @override
  void goToPrevMatch() => _searcher.goToPrevMatch();

  @override
  void dispose() {
    _searcher.removeListener(notifyListeners);
    _searcher.dispose();
    super.dispose();
  }
}
