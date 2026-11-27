import 'package:flutter/widgets.dart';
import 'package:reader_documents/features/documents/data/models/document_file.dart';

import 'thumbnail/document_thumbnail_engine.dart';
import 'thumbnail/document_thumbnail_registry.dart';
import 'thumbnail/docx_document_thumbnail_engine.dart';
import 'thumbnail/pdf_document_thumbnail_engine.dart';

@immutable
final class DocumentPageHeroTag {
  DocumentPageHeroTag.of(DocumentFile file) : path = file.path;

  final String path;

  @override
  bool operator ==(Object other) =>
      other is DocumentPageHeroTag && other.path == path;

  @override
  int get hashCode => Object.hash(DocumentPageHeroTag, path);
}

class DocumentThumbnail extends StatelessWidget {
  const DocumentThumbnail._({
    required this.file,
    required this.engine,
    required this.preview,
    super.key,
  });

  static DocumentThumbnailRegistry registry = const DocumentThumbnailRegistry([
    PdfDocumentThumbnailEngine(),
    DocxDocumentThumbnailEngine(),
  ]);

  static Widget? of(DocumentFile file, {bool preview = true}) {
    for (final engine in registry.engines) {
      if (engine.supports(file.type)) {
        return DocumentThumbnail._(
          key: ValueKey('${file.path}:$preview'),
          file: file,
          engine: engine,
          preview: preview,
        );
      }
    }
    return null;
  }

  final DocumentFile file;
  final DocumentThumbnailEngine engine;
  final bool preview;

  @override
  Widget build(BuildContext context) =>
      engine.build(context, file, preview: preview);
}
