import 'dart:isolate';
import 'dart:typed_data';

import 'pdf_converter.dart';

final class IsolatePdfConverter implements PdfConverter {
  const IsolatePdfConverter(this._inner);

  final PdfConverter _inner;

  @override
  String get id => _inner.id;

  @override
  Future<Uint8List> toPdf(Uint8List source) {
    final inner = _inner;
    return Isolate.run(() => inner.toPdf(source), debugName: 'pdf-conversion');
  }
}
