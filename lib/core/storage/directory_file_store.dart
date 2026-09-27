import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Base for repositories backed by a single named subdirectory under the
/// app's documents directory, created on first access.
///
/// A subclass only describes [directoryName]; domain-specific file
/// operations (listing, filtering, copying, deleting) stay in the subclass.
abstract class DirectoryFileStore {
  const DirectoryFileStore();

  /// Name of the subdirectory this store resolves, relative to the app's
  /// documents directory. Must be unique per subclass.
  String get directoryName;

  Future<Directory> resolveDirectory() async {
    final root = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(root.path, directoryName));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }
}
