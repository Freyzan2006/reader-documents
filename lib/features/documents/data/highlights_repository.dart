import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'pdf_highlight.dart';

class HighlightsRepository {
  const HighlightsRepository();

  static const _keyPrefix = 'pdf_highlights.';

  Future<List<PdfHighlight>> load(String documentPath) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyFor(documentPath));
    if (raw == null) return const [];
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((entry) => PdfHighlight.fromJson(entry as Map<String, dynamic>))
        .toList();
  }

  Future<void> save(String documentPath, List<PdfHighlight> highlights) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _keyFor(documentPath),
      jsonEncode(highlights.map((h) => h.toJson()).toList()),
    );
  }

  String _keyFor(String documentPath) => '$_keyPrefix$documentPath';
}
