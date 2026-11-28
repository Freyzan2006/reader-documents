import 'dart:io';

import '../models/document_file.dart';
import 'converted_pdf_cache.dart';
import 'pdf_converter.dart';
import 'pdf_projection.dart';

final class CachedPdfProjection implements PdfProjection {
  CachedPdfProjection({required this.converter, required this.cache});

  final PdfConverter converter;
  final ConvertedPdfCache cache;

  final Map<String, Future<String>> _inFlight = {};

  @override
  Future<String> pdfPathFor(DocumentFile file) {
    final key = [
      converter.id,
      file.path,
      file.sizeBytes,
      file.modifiedAt.microsecondsSinceEpoch,
    ].join('|');
    final existing = _inFlight[key];
    if (existing != null) return existing;

    // Block body: returning the removed future makes `pending` await itself.
    final pending = _project(file, key).whenComplete(() {
      _inFlight.remove(key);
    });
    return _inFlight[key] = pending;
  }

  Future<String> _project(DocumentFile file, String key) async {
    final cached = await cache.lookup(key);
    if (cached != null) return cached;

    final pdf = await converter.toPdf(await File(file.path).readAsBytes());
    if (pdf.isEmpty) throw StateError('Conversion produced an empty PDF');
    return cache.store(key, pdf);
  }
}
