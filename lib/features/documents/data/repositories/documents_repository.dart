import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:reader_documents/core/storage/directory_file_store.dart';

import '../models/document_file.dart';

class DocumentsRepository extends DirectoryFileStore {
  const DocumentsRepository();

  static const _allowedExtensions = {'pdf', 'docx', 'djvu'};

  @override
  String get directoryName => 'documents';

  Future<List<DocumentFile>> list() async {
    final dir = await resolveDirectory();
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
    final dir = await resolveDirectory();
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
