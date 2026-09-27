import 'package:shared_preferences/shared_preferences.dart';

/// Base for repositories that persist a single app-wide value as several
/// separate primitive SharedPreferences keys (one per field), as opposed to
/// [JsonGlobalStore], which persists the whole value as one JSON blob under
/// one key.
///
/// A subclass only describes how to read/write its own fields given an
/// already-resolved [SharedPreferences] instance via [readFields] and
/// [writeFields].
abstract class FlatGlobalStore<T> {
  const FlatGlobalStore();

  Future<T> readFields(SharedPreferences prefs);
  Future<void> writeFields(SharedPreferences prefs, T value);

  Future<T> load() async {
    final prefs = await SharedPreferences.getInstance();
    return readFields(prefs);
  }

  Future<void> save(T value) async {
    final prefs = await SharedPreferences.getInstance();
    await writeFields(prefs, value);
  }
}
