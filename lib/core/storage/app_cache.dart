import 'dart:io';

abstract interface class AppCache {
  Future<int> size();

  Future<int> clear();
}

final class DirectoryAppCache implements AppCache {
  const DirectoryAppCache(this.directories);

  final List<Future<Directory> Function()> directories;

  @override
  Future<int> size() async {
    var total = 0;
    for (final resolve in directories) {
      final dir = await resolve();
      if (!await dir.exists()) continue;
      await for (final entity in dir.list(recursive: true)) {
        if (entity is File) {
          try {
            total += await entity.length();
          } on FileSystemException {
            continue;
          }
        }
      }
    }
    return total;
  }

  @override
  Future<int> clear() async {
    final before = await size();
    for (final resolve in directories) {
      final dir = await resolve();
      if (!await dir.exists()) continue;
      await for (final entity in dir.list()) {
        try {
          await entity.delete(recursive: true);
        } on FileSystemException {
          continue;
        }
      }
    }
    return before - await size();
  }
}
