import 'package:reader_documents/core/storage/primitive_document_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Reading position for formats with no addressable page numbers, stored as a
/// fraction (0..1) of the scrollable extent.
///
/// Kept apart from [ReadingProgressRepository] rather than folded into it so
/// page-based progress (PDF) and offset-based progress (DOCX) never share a
/// key or a value type.
class ReadingOffsetRepository extends PrimitiveDocumentStore<double> {
  const ReadingOffsetRepository();

  @override
  String get keyPrefix => 'reading_progress.offset.';

  @override
  double? read(SharedPreferences prefs, String key) => prefs.getDouble(key);

  @override
  Future<void> write(SharedPreferences prefs, String key, double value) =>
      prefs.setDouble(key, value);
}