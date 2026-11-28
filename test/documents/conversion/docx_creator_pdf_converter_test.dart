import 'dart:convert';
import 'dart:io';

import 'package:docx_creator/docx_creator.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reader_documents/features/documents/data/conversion/docx_creator/docx_creator_pdf_converter.dart';
import 'package:reader_documents/features/documents/data/conversion/fonts/asset_font_library.dart';
import 'package:reader_documents/features/documents/data/conversion/isolate_pdf_converter.dart';

// Verifies the adapter against its own library; nothing else in the app may
// import docx_creator.
String _textOf(DocxNode node) => switch (node) {
  DocxText(:final content) => content,
  DocxParagraph(:final children) => children.map(_textOf).join(),
  DocxList(:final items) =>
    items.expand((item) => item.children).map(_textOf).join(' '),
  DocxTable(:final rows) =>
    rows
        .expand((row) => row.cells)
        .expand((cell) => cell.children)
        .map(_textOf)
        .join(' '),
  _ => '',
};

void main() {
  Future<String> pdfText(String fixture) async {
    final source = File('test/fixtures/docx/$fixture.docx').readAsBytesSync();
    final pdf = await const DocxCreatorPdfConverter().toPdf(source);
    final document = await PdfReader.loadFromBytes(pdf);
    return document.elements.map(_textOf).join(' ');
  }

  test('text sharing a run with a break or tab is kept', () async {
    final text = await pdfText('mixed_runs');
    expect(text, contains('Item text'));
    expect(text, contains('Before tab'));
    expect(text, contains('after tab'));
  });

  for (final fixture in [
    'paragraph_metrics',
    'fonts',
    'tables',
    'lists',
    'mixed_runs',
  ]) {
    test('$fixture converts to a readable PDF', () async {
      final source = File('test/fixtures/docx/$fixture.docx').readAsBytesSync();
      final pdf = await const DocxCreatorPdfConverter().toPdf(source);
      final document = await PdfReader.loadFromBytes(pdf);

      expect(utf8.decode(pdf.sublist(0, 5)), '%PDF-');
      expect(document.pageCount, greaterThanOrEqualTo(1));
      expect(document.elements.map(_textOf).join(' ').trim(), isNotEmpty);
    });
  }

  test(
    'runs get substitute fonts with the right bold and italic face',
    () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      final fonts = await const AssetFontLibrary().load();
      final source = File('test/fixtures/docx/font_faces.docx')
          .readAsBytesSync();
      final pdf = latin1.decode(
        await DocxCreatorPdfConverter(fonts: fonts).toPdf(source),
      );

      for (final face in [
        'substitute-serif-regular',
        'substitute-serif-bold',
        'substitute-serif-italic',
        'substitute-carlito-regular',
        'substitute-sans-regular',
      ]) {
        expect(pdf, contains('/$face'), reason: face);
      }
      expect(pdf, isNot(contains('/substitute-serif-boldItalic')));
    },
  );

  test('runs inside a background isolate', () async {
    final source = File('test/fixtures/docx/tables.docx').readAsBytesSync();
    final pdf = await const IsolatePdfConverter(DocxCreatorPdfConverter())
        .toPdf(source);
    expect(utf8.decode(pdf.sublist(0, 5)), '%PDF-');
  });
}
