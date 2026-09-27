import 'package:shared_preferences/shared_preferences.dart';

/// Base for repositories that persist one primitive value per document,
/// keyed by the document's file path — as opposed to [JsonDocumentStore],
/// which JSON-encodes its per-document value.
///
/// A subclass only describes its key prefix and how to read/write [T]
/// directly against an already-resolved [SharedPreferences] instance via
/// [read] and [write] (e.g. `prefs.getInt`/`prefs.setInt`).
abstract class PrimitiveDocumentStore<T> {
  const PrimitiveDocumentStore();

  /// Prefix distinguishing this store's keys from other stores' in
  /// SharedPreferences. Must be unique per subclass.
  String get keyPrefix;

  T? read(SharedPreferences prefs, String key);
  Future<void> write(SharedPreferences prefs, String key, T value);

  /// Loads the value stored for [documentPath], or `null` if nothing has
  /// been saved for it yet.
  Future<T?> load(String documentPath) async {
    final prefs = await SharedPreferences.getInstance();
    return read(prefs, _keyFor(documentPath));
  }

  Future<void> save(String documentPath, T value) async {
    final prefs = await SharedPreferences.getInstance();
    await write(prefs, _keyFor(documentPath), value);
  }

  Future<void> clear(String documentPath) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyFor(documentPath));
  }

  String _keyFor(String documentPath) => '$keyPrefix$documentPath';
}
