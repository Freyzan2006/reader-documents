import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'tag_definition.dart';

/// Stores the app-wide tag vocabulary (name + color), shared across every
/// document. Not a [JsonDocumentStore] — that base is keyed per document
/// path, and this is a single global list instead.
class TagDefinitionsRepository {
  const TagDefinitionsRepository();

  static const _key = 'tag_definitions';

  Future<List<TagDefinition>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return const [];
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((entry) => TagDefinition.fromJson(entry as Map<String, dynamic>))
        .toList();
  }

  Future<void> save(List<TagDefinition> definitions) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(definitions.map((d) => d.toJson()).toList()),
    );
  }
}
