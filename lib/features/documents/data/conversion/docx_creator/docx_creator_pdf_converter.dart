import 'dart:typed_data';

import 'package:docx_creator/docx_creator.dart';

import '../docx/ooxml_run_splitter.dart';
import '../fonts/substitute_fonts.dart';
import '../pdf_converter.dart';
import 'font_substitution.dart';

final class DocxCreatorPdfConverter implements PdfConverter {
  const DocxCreatorPdfConverter({this.fonts = const SubstituteFonts.none()});

  static const pipelineId = 'docx_creator-1.4.0-v3';

  final SubstituteFonts fonts;

  @override
  String get id => pipelineId;

  @override
  Future<Uint8List> toPdf(Uint8List source) async {
    final document = await DocxReader.loadFromBytes(splitMixedRuns(source));
    final exporter = PdfExporter();
    // The library's one-call DOCX→PDF helper skips embedded fonts.
    for (final font in document.fonts) {
      exporter.registerFont(font.familyName, font.bytes);
    }
    return exporter.exportToBytes(substituteFonts(document, fonts, exporter));
  }
}
