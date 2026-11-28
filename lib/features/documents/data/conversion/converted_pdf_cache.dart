import 'dart:typed_data';

abstract interface class ConvertedPdfCache {
  /// Path of the PDF stored under [key], or null if there is none.
  Future<String?> lookup(String key);

  /// Stores [pdf] under [key] and returns its path.
  Future<String> store(String key, Uint8List pdf);
}
