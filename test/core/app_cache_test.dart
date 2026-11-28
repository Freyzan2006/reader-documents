import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:reader_documents/core/storage/app_cache.dart';

void main() {
  late Directory root;
  late Directory previews;
  late Directory temp;

  setUp(() async {
    root = await Directory.systemTemp.createTemp('app_cache_test');
    previews = await Directory(p.join(root.path, 'previews')).create();
    temp = await Directory(p.join(root.path, 'temp')).create();
  });
  tearDown(() => root.delete(recursive: true));

  DirectoryAppCache cache() =>
      DirectoryAppCache([() async => previews, () async => temp]);

  test('size sums files in every directory, including nested ones', () async {
    await File(p.join(previews.path, 'a.pdf'))
        .writeAsBytes(List.filled(100, 0));
    final nested = await Directory(p.join(temp.path, 'picker')).create();
    await File(p.join(nested.path, 'b.docx')).writeAsBytes(List.filled(50, 0));

    expect(await cache().size(), 150);
  });

  test('clear empties the directories but keeps them', () async {
    await File(p.join(previews.path, 'a.pdf'))
        .writeAsBytes(List.filled(100, 0));
    await Directory(p.join(temp.path, 'picker')).create();

    expect(await cache().clear(), 100);
    expect(await cache().size(), 0);
    expect(previews.existsSync(), isTrue);
    expect(previews.listSync(), isEmpty);
    expect(temp.listSync(), isEmpty);
  });

  test('a missing directory counts as empty', () async {
    final gone = Directory(p.join(root.path, 'gone'));
    expect(await DirectoryAppCache([() async => gone]).size(), 0);
    expect(await DirectoryAppCache([() async => gone]).clear(), 0);
  });
}
