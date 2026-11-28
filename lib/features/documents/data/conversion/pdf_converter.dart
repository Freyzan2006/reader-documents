import 'dart:typed_data';

abstract interface class PdfConverter {
  /// Identifies the conversion pipeline. Part of the cache key, so swapping or
  /// upgrading the implementation invalidates PDFs it did not produce.
  String get id;

  Future<Uint8List> toPdf(Uint8List source);
}
