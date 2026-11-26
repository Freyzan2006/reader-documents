import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reader_documents/features/documents/data/models/document_file.dart';

class DocumentSelection {
  const DocumentSelection({
    this.files = const <DocumentFile>[],
    this.available = const <DocumentFile>[],
  });

  final List<DocumentFile> files;
  final List<DocumentFile> available;

  bool get isEmpty => files.isEmpty;
  bool get isNotEmpty => !isEmpty;

  bool contains(String path) => files.any((file) => file.path == path);
}

class DocumentSelectionNotifier extends Notifier<DocumentSelection> {
  @override
  DocumentSelection build() => const DocumentSelection();

  void start(DocumentFile file, List<DocumentFile> available) =>
      state = DocumentSelection(files: [file], available: available);

  void toggle(DocumentFile file) {
    final files = [...state.files];
    final index = files.indexWhere((item) => item.path == file.path);
    if (index >= 0) {
      files.removeAt(index);
    } else {
      files.add(file);
    }
    state = DocumentSelection(files: files, available: state.available);
  }

  void selectAll() {
    final available = state.available;
    final allSelected = state.files.length == available.length;
    state = DocumentSelection(
      files: allSelected ? const <DocumentFile>[] : available,
      available: available,
    );
  }

  void clear() => state = const DocumentSelection();

  void sync(List<DocumentFile> available) {
    final paths = available.map((file) => file.path).toSet();
    final files = state.files
        .where((file) => paths.contains(file.path))
        .toList();
    state = files.isEmpty
        ? const DocumentSelection()
        : DocumentSelection(files: files, available: available);
  }
}

final documentSelectionProvider =
    NotifierProvider<DocumentSelectionNotifier, DocumentSelection>(
      DocumentSelectionNotifier.new,
    );
