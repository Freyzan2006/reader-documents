import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reader_documents/features/documents/data/conversion/docx/ooxml_run_splitter.dart';

const _ns =
    'xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"';

Uint8List _docx(String body) {
  final xml = utf8.encode(
    '<w:document $_ns><w:body>$body</w:body></w:document>',
  );
  final archive = Archive()
    ..addFile(ArchiveFile.bytes('word/document.xml', xml))
    ..addFile(ArchiveFile.bytes('word/styles.xml', utf8.encode('<x/>')));
  return Uint8List.fromList(ZipEncoder().encode(archive));
}

String _body(Uint8List docx) {
  final xml = utf8.decode(
    ZipDecoder().decodeBytes(docx).findFile('word/document.xml')!.content,
  );
  return xml.substring(xml.indexOf('<w:body>') + 8, xml.indexOf('</w:body>'));
}

void main() {
  test('splits a run into one run per content element', () {
    final out = splitMixedRuns(
      _docx(
        '<w:p><w:r><w:rPr><w:b/></w:rPr>'
        '<w:t>one</w:t><w:br/><w:tab/><w:t>two</w:t></w:r></w:p>',
      ),
    );
    expect(
      _body(out),
      '<w:p>'
      '<w:r><w:rPr><w:b/></w:rPr><w:t>one</w:t></w:r>'
      '<w:r><w:rPr><w:b/></w:rPr><w:br/></w:r>'
      '<w:r><w:rPr><w:b/></w:rPr><w:tab/></w:r>'
      '<w:r><w:rPr><w:b/></w:rPr><w:t>two</w:t></w:r>'
      '</w:p>',
    );
  });

  test('maps elements the reader drops onto ones it understands', () {
    final out = splitMixedRuns(
      _docx('<w:p><w:r><w:t>a</w:t><w:noBreakHyphen/><w:cr/></w:r></w:p>'),
    );
    expect(_body(out), contains('<w:t>‑</w:t>'));
    expect(_body(out), contains('<w:br/>'));
  });

  test('leaves simple runs and the rest of the package untouched', () {
    final source = _docx('<w:p><w:r><w:t>plain</w:t></w:r></w:p>');
    expect(identical(splitMixedRuns(source), source), isTrue);
  });
}
