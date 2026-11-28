import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:reader_documents/features/documents/data/conversion/cached_pdf_projection.dart';
import 'package:reader_documents/features/documents/data/conversion/converted_pdf_cache.dart';
import 'package:reader_documents/features/documents/data/conversion/pdf_converter.dart';
import 'package:reader_documents/features/documents/data/models/document_file.dart';

final class _FakeConverter implements PdfConverter {
  _FakeConverter({this.id = 'fake-v1', this.result});

  @override
  final String id;
  final Future<Uint8List> Function()? result;
  int calls = 0;

  @override
  Future<Uint8List> toPdf(Uint8List source) {
    calls++;
    return result?.call() ??
        Future.value(Uint8List.fromList(utf8.encode('$id:$calls')));
  }
}

final class _MemoryCache implements ConvertedPdfCache {
  final entries = <String, Uint8List>{};

  @override
  Future<String?> lookup(String key) async =>
      entries.containsKey(key) ? key : null;

  @override
  Future<String> store(String key, Uint8List pdf) async {
    entries[key] = pdf;
    return key;
  }
}

void main() {
  late Directory temp;
  late DocumentFile file;

  setUp(() async {
    temp = await Directory.systemTemp.createTemp('cached_pdf_projection_test');
    final source = File('${temp.path}/source.docx')
      ..writeAsBytesSync(utf8.encode('docx bytes'));
    file = DocumentFile(
      path: source.path,
      name: 'source.docx',
      type: DocumentType.docx,
      sizeBytes: source.lengthSync(),
      modifiedAt: source.statSync().modified,
    );
  });

  tearDown(() => temp.delete(recursive: true));

  test('reuses the cached PDF until the source changes', () async {
    final converter = _FakeConverter();
    final projection = CachedPdfProjection(
      converter: converter,
      cache: _MemoryCache(),
    );

    final first = await projection.pdfPathFor(file);
    expect(await projection.pdfPathFor(file), first);
    expect(converter.calls, 1);

    final edited = file.copyWith(sizeBytes: file.sizeBytes + 1);
    expect(await projection.pdfPathFor(edited), isNot(first));
    expect(converter.calls, 2);
  });

  test('a different converter does not reuse foreign PDFs', () async {
    final cache = _MemoryCache();
    await CachedPdfProjection(
      converter: _FakeConverter(id: 'a'),
      cache: cache,
    ).pdfPathFor(file);

    final other = _FakeConverter(id: 'b');
    await CachedPdfProjection(converter: other, cache: cache).pdfPathFor(file);
    expect(other.calls, 1);
  });

  test('concurrent requests share one conversion', () async {
    final gate = Completer<Uint8List>();
    final converter = _FakeConverter(result: () => gate.future);
    final projection = CachedPdfProjection(
      converter: converter,
      cache: _MemoryCache(),
    );

    final first = projection.pdfPathFor(file);
    final second = projection.pdfPathFor(file);
    expect(identical(first, second), isTrue);

    gate.complete(Uint8List.fromList([1]));
    expect(await first, await second);
    expect(converter.calls, 1);
  });

  test('rejects an empty conversion result', () async {
    final projection = CachedPdfProjection(
      converter: _FakeConverter(result: () async => Uint8List(0)),
      cache: _MemoryCache(),
    );
    await expectLater(projection.pdfPathFor(file), throwsStateError);
  });
}
