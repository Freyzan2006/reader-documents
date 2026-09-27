import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter/widgets.dart';
import 'package:reader_documents/features/documents/data/document_file.dart';
import 'package:reader_documents/features/documents/data/document_highlight.dart';

import 'contract/document_viewer.dart';
import 'contract/document_viewer_controller.dart';
import 'pdf/pdf_document_viewer.dart';

abstract final class DocumentViewerFactory {
  static bool supports(DocumentType type) => switch (type) {
    DocumentType.pdf => true,
    DocumentType.docx || DocumentType.djvu || DocumentType.other => false,
  };

  static DocumentViewer build({
    required DocumentFile file,
    required int initialPageNumber,
    required ValueListenable<List<DocumentHighlight>> highlights,
    required ValueChanged<int?> onPageChanged,
    required ValueChanged<DocumentViewerController> onReady,
    required DocumentBackgroundTapHandler onBackgroundTap,
    required DocumentPasswordProvider passwordProvider,
    required DocumentContextMenuBuilder buildContextMenu,
    required DocumentMagnifierBuilder buildMagnifier,
    required DocumentErrorBannerBuilder buildErrorBanner,
    required DocumentLoadingBannerBuilder buildLoadingBanner,
  }) => switch (file.type) {
    DocumentType.pdf => PdfDocumentViewer(
      file: file,
      initialPageNumber: initialPageNumber,
      highlights: highlights,
      onPageChanged: onPageChanged,
      onReady: onReady,
      onBackgroundTap: onBackgroundTap,
      passwordProvider: passwordProvider,
      buildContextMenu: buildContextMenu,
      buildMagnifier: buildMagnifier,
      buildErrorBanner: buildErrorBanner,
      buildLoadingBanner: buildLoadingBanner,
    ),
    DocumentType.docx || DocumentType.djvu || DocumentType.other =>
      throw UnsupportedError('No viewer registered for ${file.type}'),
  };
}
