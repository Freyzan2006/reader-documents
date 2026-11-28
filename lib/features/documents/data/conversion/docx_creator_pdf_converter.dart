import 'dart:typed_data';

import 'package:docx_creator/docx_creator.dart';

import 'pdf_converter.dart';

final class DocxCreatorPdfConverter implements PdfConverter {
  const DocxCreatorPdfConverter();

  @override
  String get id => 'docx_creator-1.4.0-v1';

  @override
  Future<Uint8List> toPdf(Uint8List source) async {
    final document = await DocxReader.loadFromBytes(source);
    final exporter = PdfExporter();
    // The library's one-call DOCX→PDF helper skips embedded fonts.
    for (final font in document.fonts) {
      exporter.registerFont(font.familyName, font.bytes);
    }
    return exporter.exportToBytes(document);
  }
}
