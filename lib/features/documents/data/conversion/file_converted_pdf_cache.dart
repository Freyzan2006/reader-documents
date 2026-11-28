import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;

import 'converted_pdf_cache.dart';

final class FileConvertedPdfCache implements ConvertedPdfCache {
  const FileConvertedPdfCache({
    required this.resolveDirectory,
    this.maxFiles = 32,
  }) : assert(maxFiles > 0);

  final Future<Directory> Function() resolveDirectory;
  final int maxFiles;

  @override
  Future<String?> lookup(String key) async {
    final file = File(p.join((await resolveDirectory()).path, _fileName(key)));
    return await file.exists() ? file.path : null;
  }

  @override
  Future<String> store(String key, Uint8List pdf) async {
    final dir = await resolveDirectory();
    final target = File(p.join(dir.path, _fileName(key)));
    await _prune(dir);

    // Rename after writing so an interrupted write never leaves a reusable
    // partial PDF.
    final temporary = File('${target.path}.tmp');
    await temporary.writeAsBytes(pdf, flush: true);
    await temporary.rename(target.path);
    return target.path;
  }

  Future<void> _prune(Directory dir) async {
    final entries = await dir.list().toList();
    for (final entry in entries) {
      if (entry is File && p.extension(entry.path) == '.tmp') {
        await entry.delete();
      }
    }
    final pdfs = entries
        .whereType<File>()
        .where((file) => p.extension(file.path) == '.pdf')
        .toList();
    if (pdfs.length < maxFiles) return;
    final byAge = <(File, DateTime)>[
      for (final file in pdfs) (file, (await file.stat()).modified),
    ]..sort((a, b) => b.$2.compareTo(a.$2));
    for (final (file, _) in byAge.skip(maxFiles - 1)) {
      await file.delete();
    }
  }

  // String.hashCode and Object.hash are seeded per process, so they cannot
  // name files that must be found again after a restart.
  static String _fileName(String key) {
    const mask = 0xFFFFFFFF;
    var a = 0x811c9dc5;
    var b = 0x01000193;
    for (final byte in utf8.encode(key)) {
      a = ((a ^ byte) * 0x01000193) & mask;
      b = ((b ^ byte) * 0x811c9dc5) & mask;
    }
    String hex(int v) => v.toRadixString(16).padLeft(8, '0');
    return '${hex(a)}${hex(b)}.pdf';
  }
}
