import 'package:flutter/rendering.dart' show SelectedContent;
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:flutter/widgets.dart';
import 'package:reader_documents/features/documents/data/models/document_highlight.dart';
import 'package:reader_documents/features/documents/presentation/viewer/contract/document_text_selection.dart';

/// Backed by Flutter's own [SelectableRegion] (via [SelectionArea]) rather
/// than anything `docx_file_viewer` exposes itself — the package renders
/// plain [Text]/[RichText] widgets with no selection API of its own, but
/// Flutter already makes any [Text] under a [SelectionArea] selectable
/// automatically, so wrapping the rendered document in one gets real
/// copy/select-all for free.
///
/// [SelectableRegionState] has no public getter for the currently selected
/// plain text — [content] is instead whatever [SelectionArea.onSelectionChanged]
/// last reported, captured by the caller and passed in fresh each time a
/// menu is about to be built.
///
/// [highlightDraft] is always null: highlighting needs the selection's
/// on-screen rects to paint over, and [SelectedContent] only exposes plain
/// text, not geometry — matching the "viewer + search only" scope already
/// agreed for this format.
class DocxDocumentTextSelection implements DocumentTextSelection {
  const DocxDocumentTextSelection(this._region, this._content);

  final SelectableRegionState _region;
  final SelectedContent? _content;

  @override
  bool get isCopyAllowed => true;

  @override
  bool get hasSelectedText => (_content?.plainText ?? '').isNotEmpty;

  /// [SelectedContent] doesn't say whether the *entire* document is
  /// currently selected, only the selected text itself — so "Select all"
  /// stays offered even once everything already is. Harmless: selecting an
  /// already-fully-selected region is a no-op.
  @override
  bool get isSelectingAllText => false;

  @override
  Future<String> getSelectedText() async => _content?.plainText ?? '';

  @override
  void copyTextSelection() {
    final text = _content?.plainText;
    if (text != null && text.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: text));
    }
  }

  @override
  void selectAllText() => _region.selectAll(SelectionChangedCause.toolbar);

  @override
  DocumentHighlightDraft? get highlightDraft => null;
}
