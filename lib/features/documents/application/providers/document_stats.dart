import 'package:reader_documents/features/documents/data/models/document_file.dart';

/// Aggregate counts derived from the document library — document count,
/// total size, and a count per format. Kept as a plain value type (not
/// computed inline in a widget) so it's independently testable and reusable
/// wherever a summary is needed, not just Home's stats strip.
class DocumentStats {
  const DocumentStats({
    required this.count,
    required this.totalBytes,
    required this.countByType,
  });

  factory DocumentStats.from(List<DocumentFile> documents) {
    final countByType = <DocumentType, int>{};
    var totalBytes = 0;
    for (final file in documents) {
      totalBytes += file.sizeBytes;
      countByType[file.type] = (countByType[file.type] ?? 0) + 1;
    }
    return DocumentStats(
      count: documents.length,
      totalBytes: totalBytes,
      countByType: countByType,
    );
  }

  final int count;
  final int totalBytes;
  final Map<DocumentType, int> countByType;
}
