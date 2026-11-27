import 'package:flutter/widgets.dart';
import 'package:reader_documents/features/documents/data/models/document_file.dart';

import 'document_thumbnail_engine.dart';

final class DocumentThumbnailRegistry {
  const DocumentThumbnailRegistry(this.engines);

  final List<DocumentThumbnailEngine> engines;

  Widget? build(BuildContext context, DocumentFile file) {
    for (final engine in engines) {
      if (engine.supports(file.type)) return engine.build(context, file);
    }
    return null;
  }
}
