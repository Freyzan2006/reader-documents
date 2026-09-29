import 'package:docx_file_viewer/docx_file_viewer.dart';
import 'package:reader_documents/features/documents/presentation/viewer/contract/document_viewer_controller.dart';

class DocxDocumentSearchSession extends DocumentSearchSession {
  DocxDocumentSearchSession(this._raw) {
    _raw.addListener(notifyListeners);
  }

  final DocxSearchController _raw;

  DocxSearchController get rawController => _raw;

  @override
  bool get isPreparing => false;

  @override
  bool get hasMatches => _raw.matches.isNotEmpty;

  @override
  int? get currentIndex =>
      _raw.currentMatchIndex >= 0 ? _raw.currentMatchIndex : null;

  @override
  int get matchCount => _raw.matchCount;

  @override
  Future<void> prepare() async {}

  @override
  void startTextSearch(String text) => _raw.search(text);

  @override
  void resetTextSearch() => _raw.clear();

  @override
  void goToNextMatch() => _raw.nextMatch();

  @override
  void goToPrevMatch() => _raw.previousMatch();

  @override
  void dispose() {
    _raw.removeListener(notifyListeners);
    super.dispose();
  }
}
