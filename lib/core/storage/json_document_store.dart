import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Base for repositories that persist one JSON-encodable value per document,
/// keyed by the document's file path.
///
/// A subclass only describes its key prefix and how to convert [T] to/from
/// the JSON-encodable structure (a [Map], [List], or primitive) via [encode]
/// and [decode] — storage, key-building, and the load/save/clear surface are
/// handled here once, so every per-document JSON store in the app follows
/// the same shape instead of reimplementing SharedPreferences plumbing.
abstract class JsonDocumentStore<T> {
  const JsonDocumentStore();

  /// Prefix distinguishing this store's keys from other stores' in
  /// SharedPreferences. Must be unique per subclass.
  String get keyPrefix;

  /// Converts [value] to a JSON-encodable structure.
  Object? encode(T value);

  /// Rebuilds a [T] from the structure produced by [encode].
  T decode(Object? json);

  /// Loads the value stored for [documentPath], or `null` if nothing has
  /// been saved for it yet.
  Future<T?> load(String documentPath) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyFor(documentPath));
    if (raw == null) return null;
    return decode(jsonDecode(raw));
  }

  Future<void> save(String documentPath, T value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyFor(documentPath), jsonEncode(encode(value)));
  }

  Future<void> clear(String documentPath) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyFor(documentPath));
  }

  /// Every stored value across all documents, keyed by document path.
  Future<Map<String, T>> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final result = <String, T>{};
    for (final key in prefs.getKeys()) {
      if (!key.startsWith(keyPrefix)) continue;
      final raw = prefs.getString(key);
      if (raw == null) continue;
      result[key.substring(keyPrefix.length)] = decode(jsonDecode(raw));
    }
    return result;
  }

  String _keyFor(String documentPath) => '$keyPrefix$documentPath';
}
