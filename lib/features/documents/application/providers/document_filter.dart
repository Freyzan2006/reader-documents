import 'package:reader_documents/features/documents/data/models/document_file.dart';

class DocumentFilter {
  const DocumentFilter([
    this.types = const {},
    this.query = '',
    this.tags = const {},
  ]);

  static const selectable = [
    DocumentType.pdf,
    DocumentType.docx,
    DocumentType.djvu,
  ];

  final Set<DocumentType> types;
  final String query;
  final Set<String> tags;

  bool get isEmpty => types.isEmpty && tags.isEmpty;

  bool selects(DocumentType type) => types.contains(type);

  bool selectsTag(String tag) => tags.contains(tag);

  bool matches(DocumentType type) => types.isEmpty || types.contains(type);

  DocumentFilter toggle(DocumentType type) => selects(type)
      ? DocumentFilter(types.difference({type}), query, tags)
      : DocumentFilter(types.union({type}), query, tags);

  DocumentFilter toggleTag(String tag) => selectsTag(tag)
      ? DocumentFilter(types, query, tags.difference({tag}))
      : DocumentFilter(types, query, tags.union({tag}));

  /// Replaces the active tag filter with just [tag] — used when jumping in
  /// from outside the Documents tab (e.g. Home's "browse by tag"), where a
  /// single fresh selection reads better than accumulating onto whatever was
  /// already filtered.
  DocumentFilter withTag(String tag) => DocumentFilter(types, query, {tag});

  DocumentFilter withQuery(String query) => DocumentFilter(types, query, tags);

  DocumentFilter clear() => DocumentFilter(const {}, query, const {});
}
