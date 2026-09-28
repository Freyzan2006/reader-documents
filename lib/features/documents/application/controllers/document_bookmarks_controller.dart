import 'package:flutter/foundation.dart';
import 'package:reader_documents/features/documents/data/models/document_bookmark.dart';
import 'package:reader_documents/features/documents/data/repositories/bookmarks_repository.dart';

class DocumentBookmarksController
    extends ValueNotifier<List<DocumentBookmark>> {
  DocumentBookmarksController(this._repository, this._documentPath)
    : super(const []);

  final BookmarksRepository _repository;
  final String _documentPath;

  Future<void> load() async {
    final bookmarks = await _repository.load(_documentPath);
    value = _sorted(bookmarks ?? const []);
  }

  bool isBookmarked(int pageNumber) =>
      value.any((b) => b.pageNumber == pageNumber);

  DocumentBookmark? forPage(int pageNumber) {
    for (final bookmark in value) {
      if (bookmark.pageNumber == pageNumber) return bookmark;
    }
    return null;
  }

  Future<void> add(int pageNumber, String note) async {
    final bookmark = DocumentBookmark.create(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      pageNumber: pageNumber,
      note: note,
    );
    value = _sorted([...value, bookmark]);
    await _repository.save(_documentPath, value);
  }

  Future<void> remove(String id) async {
    value = value.where((b) => b.id != id).toList();
    await _repository.save(_documentPath, value);
  }

  List<DocumentBookmark> _sorted(List<DocumentBookmark> bookmarks) =>
      [...bookmarks]..sort((a, b) => a.pageNumber.compareTo(b.pageNumber));
}
