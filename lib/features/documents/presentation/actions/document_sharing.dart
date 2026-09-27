import 'package:reader_documents/features/documents/data/document_file.dart';
import 'package:share_plus/share_plus.dart';

abstract final class DocumentSharing {
  static Future<void> share(DocumentFile file) =>
      SharePlus.instance.share(ShareParams(files: [XFile(file.path)]));
}
