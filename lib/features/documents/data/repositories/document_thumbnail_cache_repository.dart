import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class DocumentThumbnailCacheRepository {
  const DocumentThumbnailCacheRepository();

  static const _dirName = 'document_thumbnails';

  Future<Directory> _resolveDir() async {
    final root = await getApplicationSupportDirectory();
    final dir = Directory(p.join(root.path, _dirName));
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  Future<File> fileFor(String documentPath, int signature) async {
    final dir = await _resolveDir();
    final name = '${documentPath.hashCode.toUnsigned(20)}_$signature.png';
    return File(p.join(dir.path, name));
  }

  Future<Uint8List?> read(String documentPath, int signature) async {
    final file = await fileFor(documentPath, signature);
    if (!await file.exists()) return null;
    return file.readAsBytes();
  }

  Future<void> write(
    String documentPath,
    int signature,
    Uint8List bytes,
  ) async {
    final file = await fileFor(documentPath, signature);
    await file.writeAsBytes(bytes, flush: true);
  }
}
