import 'package:reader_documents/features/documents/data/document_highlight.dart';

abstract class DocumentTextSelection {
  bool get isCopyAllowed;
  bool get hasSelectedText;
  bool get isSelectingAllText;
  Future<String> getSelectedText();
  void copyTextSelection();
  void selectAllText();
  DocumentHighlightDraft? get highlightDraft;
}
