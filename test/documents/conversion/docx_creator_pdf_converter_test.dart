import 'dart:convert';
import 'dart:io';

import 'package:docx_creator/docx_creator.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reader_documents/features/documents/data/conversion/docx_creator_pdf_converter.dart';
import 'package:reader_documents/features/documents/data/conversion/isolate_pdf_converter.dart';

// Verifies the adapter against its own library; nothing else in the app may
// import docx_creator.
String _textOf(DocxNode node) => switch (node) {
  DocxText(:final content) => content,
  DocxParagraph(:final children) => children.map(_textOf).join(),
  DocxTable(:final rows) =>
    rows
        .expand((row) => row.cells)
        .expand((cell) => cell.children)
        .map(_textOf)
        .join(' '),
  _ => '',
};

void main() {
  for (final fixture in ['paragraph_metrics', 'fonts', 'tables', 'lists']) {
    test('$fixture converts to a readable PDF', () async {
      final source = File('test/fixtures/docx/$fixture.docx').readAsBytesSync();
      final pdf = await const DocxCreatorPdfConverter().toPdf(source);
      final document = await PdfReader.loadFromBytes(pdf);

      expect(utf8.decode(pdf.sublist(0, 5)), '%PDF-');
      expect(document.pageCount, greaterThanOrEqualTo(1));
      expect(document.elements.map(_textOf).join(' ').trim(), isNotEmpty);
    });
  }

  test('runs inside a background isolate', () async {
    final source = File('test/fixtures/docx/tables.docx').readAsBytesSync();
    final pdf = await const IsolatePdfConverter(DocxCreatorPdfConverter())
        .toPdf(source);
    expect(utf8.decode(pdf.sublist(0, 5)), '%PDF-');
  });
}
