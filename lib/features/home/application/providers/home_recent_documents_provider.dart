import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reader_documents/features/documents/application/documents_providers.dart';
import 'package:reader_documents/features/documents/data/models/document_file.dart';

/// [recentDocumentsProvider] with the single most-recent document removed.
///
/// Home-specific, not a generic documents concept: it exists only because
/// Home's "continue reading" card already shows that one document
/// prominently, so the "Recently opened" list beneath it shows the rest of
/// the history instead of repeating the same entry.
final homeOlderDocumentsProvider = Provider<AsyncValue<List<DocumentFile>>>((
  ref,
) {
  final recent = ref.watch(recentDocumentsProvider);
  return recent.whenData((files) => files.skip(1).toList());
});
