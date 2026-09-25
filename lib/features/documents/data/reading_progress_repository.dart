import 'package:shared_preferences/shared_preferences.dart';

class ReadingProgressRepository {
  const ReadingProgressRepository();

  static const _keyPrefix = 'reading_progress.page.';

  Future<int?> loadPage(String documentPath) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyFor(documentPath));
  }

  Future<void> savePage(String documentPath, int pageNumber) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyFor(documentPath), pageNumber);
  }

  String _keyFor(String documentPath) => '$_keyPrefix$documentPath';
}
