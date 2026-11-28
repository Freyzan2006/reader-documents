// Generates small, deterministic DOCX fixtures for the DOCX → PDF tests.
//
// Run from the repository root:
//
//   dart run tool/generate_docx_fixtures.dart
//
// The fixtures exercise OOXML attributes that docx_creator's writer cannot
// emit (character spacing, hRule, percentage table widths, numbering start),
// so they are assembled as raw package parts instead.

import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';

const _w = 'http://schemas.openxmlformats.org/wordprocessingml/2006/main';
const _r =
    'http://schemas.openxmlformats.org/officeDocument/2006/relationships';
const _pkgRel = 'http://schemas.openxmlformats.org/package/2006/relationships';

const _contentTypes = '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">
  <Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>
  <Default Extension="xml" ContentType="application/xml"/>
  <Override PartName="/word/document.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml"/>
  <Override PartName="/word/styles.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.styles+xml"/>
</Types>''';

const _rootRels =
    '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="$_pkgRel">
  <Relationship Id="rId1" Type="$_r/officeDocument" Target="word/document.xml"/>
</Relationships>''';

const _documentRels = '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="$_pkgRel"/>''';

const _styles =
    '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:styles xmlns:w="$_w">
  <w:docDefaults>
    <w:rPrDefault>
      <w:rPr>
        <w:rFonts w:ascii="Calibri" w:hAnsi="Calibri"/>
        <w:sz w:val="22"/>
      </w:rPr>
    </w:rPrDefault>
  </w:docDefaults>
</w:styles>''';

const _sectPr = '''<w:sectPr>
  <w:pgSz w:w="11906" w:h="16838"/>
  <w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440"/>
</w:sectPr>''';

String _document(String body) =>
    '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:document xmlns:w="$_w" xmlns:r="$_r">
  <w:body>$body$_sectPr</w:body>
</w:document>''';

String _paragraph(String content, {String? pPr}) =>
    '<w:p>${pPr ?? ''}$content</w:p>';

String _run(String text, {String? rPr}) =>
    '<w:r>${rPr ?? ''}<w:t xml:space="preserve">$text</w:t></w:r>';

String _paragraphMetrics() => _document(
  [
    _paragraph(
      _run('Letter spaced', rPr: '<w:rPr><w:spacing w:val="60"/></w:rPr>'),
      pPr:
          '<w:pPr><w:spacing w:before="240" w:after="120" '
          'w:line="360" w:lineRule="exact"/></w:pPr>',
    ),
    _paragraph(
      _run('Tight', rPr: '<w:rPr><w:spacing w:val="0"/></w:rPr>'),
      pPr: '<w:pPr><w:spacing w:line="240" w:lineRule="atLeast"/></w:pPr>',
    ),
    _paragraph(_run('Plain')),
  ].join(),
);

String _fonts() => _document(
  [
    _paragraph(
      _run(
        'Aptos',
        rPr:
            '<w:rPr><w:rFonts w:ascii="Aptos" '
            'w:hAnsi="Aptos"/><w:sz w:val="24"/></w:rPr>',
      ),
    ),
    _paragraph(
      _run(
        'Theme body',
        rPr:
            '<w:rPr><w:rFonts '
            'w:asciiTheme="minorHAnsi"/></w:rPr>',
      ),
    ),
    _paragraph(
      _run(
        'Times',
        rPr:
            '<w:rPr><w:rFonts w:ascii="Times New Roman" '
            'w:hAnsi="Times New Roman"/><w:sz w:val="24"/></w:rPr>',
      ),
    ),
  ].join(),
);

String _tables() {
  final table =
      '''
<w:tbl>
  <w:tblPr>
    <w:tblW w:w="5000" w:type="pct"/>
    <w:tblCellMar>
      <w:top w:w="0" w:type="dxa"/>
      <w:left w:w="0" w:type="dxa"/>
      <w:bottom w:w="0" w:type="dxa"/>
      <w:right w:w="0" w:type="dxa"/>
    </w:tblCellMar>
  </w:tblPr>
  <w:tblGrid><w:gridCol w:w="2000"/><w:gridCol w:w="2000"/><w:gridCol w:w="2000"/></w:tblGrid>
  <w:tr>
    <w:trPr><w:trHeight w:val="400" w:hRule="atLeast"/></w:trPr>
    <w:tc><w:tcPr><w:gridSpan w:val="2"/></w:tcPr>${_paragraph(_run('merged'))}</w:tc>
    <w:tc>${_paragraph(_run('right'))}</w:tc>
  </w:tr>
  <w:tr>
    <w:tc><w:tcPr><w:vMerge w:val="restart"/></w:tcPr>${_paragraph(_run('tall'))}</w:tc>
    <w:tc>${_paragraph(_run('b'))}</w:tc>
    <w:tc>${_paragraph(_run('c'))}</w:tc>
  </w:tr>
  <w:tr>
    <w:tc><w:tcPr><w:vMerge/></w:tcPr>${_paragraph(_run(''))}</w:tc>
    <w:tc>${_paragraph(_run('e'))}</w:tc>
    <w:tc>${_paragraph(_run('f'))}</w:tc>
  </w:tr>
</w:tbl>''';
  return _document(table + _paragraph(_run('After table')));
}

const _numbering =
    '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:numbering xmlns:w="$_w">
  <w:abstractNum w:abstractNumId="0">
    <w:lvl w:ilvl="0">
      <w:start w:val="3"/>
      <w:numFmt w:val="decimal"/>
      <w:lvlText w:val="%1."/>
      <w:pPr><w:ind w:left="720" w:hanging="360"/></w:pPr>
    </w:lvl>
    <w:lvl w:ilvl="1">
      <w:start w:val="1"/>
      <w:numFmt w:val="lowerRoman"/>
      <w:lvlText w:val="%2."/>
      <w:pPr><w:ind w:left="1440" w:hanging="360"/></w:pPr>
    </w:lvl>
  </w:abstractNum>
  <w:num w:numId="1"><w:abstractNumId w:val="0"/></w:num>
</w:numbering>''';

String _numberedParagraph(int level, String text) => _paragraph(
  _run(text),
  pPr:
      '<w:pPr><w:numPr><w:ilvl w:val="$level"/>'
      '<w:numId w:val="1"/></w:numPr></w:pPr>',
);

String _lists() => _document(
  [
    _numberedParagraph(0, 'First'),
    _numberedParagraph(1, 'Nested one'),
    _numberedParagraph(1, 'Nested two'),
    _numberedParagraph(0, 'Second'),
  ].join(),
);

Map<String, String> _parts(String body, {String? numbering}) => {
  '[Content_Types].xml': _contentTypes,
  '_rels/.rels': _rootRels,
  'word/document.xml': body,
  'word/_rels/document.xml.rels': _documentRels,
  'word/styles.xml': _styles,
  ...(numbering == null
      ? const <String, String>{}
      : {'word/numbering.xml': numbering}),
};

void _write(String directory, String name, Map<String, String> parts) {
  final archive = Archive();
  for (final entry in parts.entries) {
    final bytes = utf8.encode(entry.value);
    archive.addFile(ArchiveFile(entry.key, bytes.length, bytes));
  }
  final encoded = ZipEncoder().encode(archive);
  File('$directory/$name').writeAsBytesSync(encoded);
}

void main(List<String> args) {
  final directory = args.isEmpty ? 'test/fixtures/docx' : args.first;
  Directory(directory).createSync(recursive: true);

  _write(directory, 'paragraph_metrics.docx', _parts(_paragraphMetrics()));
  _write(directory, 'fonts.docx', _parts(_fonts()));
  _write(directory, 'tables.docx', _parts(_tables()));
  _write(directory, 'lists.docx', _parts(_lists(), numbering: _numbering));

  stdout.writeln('Wrote 4 DOCX fixtures to $directory');
}
