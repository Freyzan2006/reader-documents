import 'package:reader_documents/features/documents/data/models/document_file.dart';

import 'document_thumbnail_engine.dart';

final class DocumentThumbnailRegistry {
  const DocumentThumbnailRegistry(this.engines);

  final List<DocumentThumbnailEngine> engines;

  DocumentThumbnailEngine? engineFor(DocumentType type) {
    for (final engine in engines) {
      if (engine.supports(type)) return engine;
    }
    return null;
  }
}
