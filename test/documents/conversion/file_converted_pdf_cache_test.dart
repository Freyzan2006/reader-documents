import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:reader_documents/features/documents/data/conversion/file_converted_pdf_cache.dart';

void main() {
  late Directory temp;

  setUp(() async {
    temp = await Directory.systemTemp.createTemp('file_pdf_cache_test');
  });

  tearDown(() => temp.delete(recursive: true));

  FileConvertedPdfCache cache({int maxFiles = 32}) => FileConvertedPdfCache(
    resolveDirectory: () async => temp,
    maxFiles: maxFiles,
  );

  test('a new instance finds what an earlier one stored', () async {
    final path = await cache().store('key', Uint8List.fromList([1, 2, 3]));

    expect(await cache().lookup('key'), path);
    expect(File(path).readAsBytesSync(), [1, 2, 3]);
    expect(await cache().lookup('other'), isNull);
  });

  test('drops the oldest PDFs once the limit is reached', () async {
    final limited = cache(maxFiles: 2);
    for (final key in ['a', 'b', 'c']) {
      await limited.store(key, Uint8List.fromList([1]));
    }

    final names = temp.listSync().map((e) => e.path).toList();
    expect(names.where((n) => n.endsWith('.pdf')), hasLength(2));
    expect(names.where((n) => n.endsWith('.tmp')), isEmpty);
    expect(await limited.lookup('c'), isNotNull);
  });
}
