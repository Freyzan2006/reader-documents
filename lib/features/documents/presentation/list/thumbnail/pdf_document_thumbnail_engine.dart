import 'package:flutter/widgets.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';
import 'package:reader_documents/features/documents/data/models/document_file.dart';

import 'document_thumbnail_engine.dart';

final class PdfDocumentThumbnailEngine implements DocumentThumbnailEngine {
  const PdfDocumentThumbnailEngine();

  static const _qualityDpi = 96.0;
  static const _performanceDpi = 48.0;

  @override
  bool supports(DocumentType type) => type == DocumentType.pdf;

  @override
  Widget build(BuildContext context, DocumentFile file, {bool preview = true}) {
    final tokens = context.tokens;
    return PdfDocumentViewBuilder.file(
      file.path,
      errorBuilder: (_, _, _) => const SizedBox.shrink(),
      loadingBuilder: (_) => const SizedBox.shrink(),
      builder: (context, document) => document == null
          ? const SizedBox.shrink()
          : PdfPageView(
              document: document,
              pageNumber: 1,
              maximumDpi: tokens.graphics == GraphicsMode.quality
                  ? _qualityDpi
                  : _performanceDpi,
              decorationBuilder: (context, pageSize, page, image) => AppReveal(
                visible: image != null,
                child: image == null
                    ? const SizedBox.expand()
                    : FittedBox(fit: BoxFit.cover, child: image),
              ),
            ),
    );
  }
}
