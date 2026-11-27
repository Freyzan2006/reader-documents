import 'package:flutter/widgets.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';
import 'package:reader_documents/features/documents/data/models/document_file.dart';

class DocumentThumbnail extends StatelessWidget {
  const DocumentThumbnail._({required this.file, super.key});

  static const _qualityDpi = 96.0;
  static const _performanceDpi = 48.0;

  static Widget? of(DocumentFile file) => file.type == DocumentType.pdf
      ? DocumentThumbnail._(key: ValueKey(file.path), file: file)
      : null;

  final DocumentFile file;

  @override
  Widget build(BuildContext context) {
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
              alignment: Alignment.topCenter,
              backgroundColor: tokens.palette.sheet,
              maximumDpi: tokens.graphics == GraphicsMode.quality
                  ? _qualityDpi
                  : _performanceDpi,
            ),
    );
  }
}
