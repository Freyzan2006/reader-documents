import 'dart:typed_data';

import 'pdf_converter.dart';

/// Builds the converter on the calling isolate for every conversion, so it can
/// read inputs a background isolate cannot (asset bundles) without keeping
/// them in memory between conversions.
final class DeferredPdfConverter implements PdfConverter {
  const DeferredPdfConverter({required this.id, required this.create});

  @override
  final String id;
  final Future<PdfConverter> Function() create;

  @override
  Future<Uint8List> toPdf(Uint8List source) async =>
      (await create()).toPdf(source);
}
