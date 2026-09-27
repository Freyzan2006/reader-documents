import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Base for repositories that persist a single JSON-encodable value shared
/// app-wide, under one fixed key — as opposed to [JsonDocumentStore], which
/// keys a value per document path.
///
/// A subclass only describes its key and how to convert [T] to/from the
/// JSON-encodable structure via [encode] and [decode].
abstract class JsonGlobalStore<T> {
  const JsonGlobalStore();

  /// The fixed SharedPreferences key. Must be unique per subclass.
  String get key;

  /// Converts [value] to a JSON-encodable structure.
  Object? encode(T value);

  /// Rebuilds a [T] from the structure produced by [encode].
  T decode(Object? json);

  /// Loads the stored value, or `null` if nothing has been saved yet.
  Future<T?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(key);
    if (raw == null) return null;
    return decode(jsonDecode(raw));
  }

  Future<void> save(T value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, jsonEncode(encode(value)));
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }
}
