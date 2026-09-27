import 'package:reader_documents/core/storage/primitive_document_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReadingProgressRepository extends PrimitiveDocumentStore<int> {
  const ReadingProgressRepository();

  @override
  String get keyPrefix => 'reading_progress.page.';

  @override
  int? read(SharedPreferences prefs, String key) => prefs.getInt(key);

  @override
  Future<void> write(SharedPreferences prefs, String key, int value) =>
      prefs.setInt(key, value);
}
