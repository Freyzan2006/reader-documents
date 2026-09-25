import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'document_file.dart';

class DocumentsRepository {
  const DocumentsRepository();

  static const _allowedExtensions = {'pdf', 'docx', 'djvu'};

  Future<Directory> _documentsDirectory() async {
    final root = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(root.path, 'documents'));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  Future<List<DocumentFile>> list() async {
    final dir = await _documentsDirectory();
    final entries = await dir.list().toList();
    final files = <DocumentFile>[];

    for (final entry in entries) {
      if (entry is! File) continue;

      final extension = p
          .extension(entry.path)
          .replaceFirst('.', '')
          .toLowerCase();
      if (!_allowedExtensions.contains(extension)) continue;

      final stat = await entry.stat();
      files.add(
        DocumentFile(
          path: entry.path,
          name: p.basename(entry.path),
          type: documentTypeFromExtension(extension),
          sizeBytes: stat.size,
          modifiedAt: stat.modified,
        ),
      );
    }

    files.sort((a, b) => b.modifiedAt.compareTo(a.modifiedAt));
    return files;
  }

  Future<DocumentFile> import(String sourcePath) async {
    final dir = await _documentsDirectory();
    final destinationPath = p.join(dir.path, p.basename(sourcePath));
    final copied = await File(sourcePath).copy(destinationPath);
    final stat = await copied.stat();
    final extension = p
        .extension(copied.path)
        .replaceFirst('.', '')
        .toLowerCase();

    return DocumentFile(
      path: copied.path,
      name: p.basename(copied.path),
      type: documentTypeFromExtension(extension),
      sizeBytes: stat.size,
      modifiedAt: stat.modified,
    );
  }

  Future<void> delete(String path) => File(path).delete();
}
