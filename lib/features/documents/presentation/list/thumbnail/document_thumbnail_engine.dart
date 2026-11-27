import 'package:flutter/widgets.dart';
import 'package:reader_documents/features/documents/data/models/document_file.dart';

abstract interface class DocumentThumbnailEngine {
  bool supports(DocumentType type);

  Widget build(BuildContext context, DocumentFile file, {bool preview = true});
}
