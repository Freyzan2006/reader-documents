import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter/widgets.dart';
import 'package:reader_documents/features/documents/data/models/document_file.dart';
import 'package:reader_documents/features/documents/data/models/document_highlight.dart';

import 'contract/document_viewer.dart';
import 'contract/document_viewer_controller.dart';
import 'docx/docx_document_viewer.dart';
import 'pdf/pdf_document_viewer.dart';

abstract final class DocumentViewerFactory {
  static bool supports(DocumentType type) => switch (type) {
    DocumentType.pdf || DocumentType.docx => true,
    DocumentType.djvu || DocumentType.other => false,
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
    double initialReadFraction = 0,
    ValueChanged<double>? onReadFractionChanged,
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
    DocumentType.docx => DocxDocumentViewer(
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
      initialReadFraction: initialReadFraction,
      onReadFractionChanged: onReadFractionChanged,
    ),
    DocumentType.djvu || DocumentType.other => throw UnsupportedError(
      'No viewer registered for ${file.type}',
    ),
  };
}
