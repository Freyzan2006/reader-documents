import 'package:reader_documents/features/documents/data/models/document_file.dart';
import 'package:share_plus/share_plus.dart';

abstract final class DocumentSharing {
  static Future<void> share(DocumentFile file) => shareMany([file]);

  static Future<void> shareMany(List<DocumentFile> files) => SharePlus.instance
      .share(ShareParams(files: [for (final file in files) XFile(file.path)]));
}
