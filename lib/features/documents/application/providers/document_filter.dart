import 'package:reader_documents/features/documents/data/models/document_file.dart';

class DocumentFilter {
  const DocumentFilter([this.types = const {}, this.query = '']);

  static const selectable = [
    DocumentType.pdf,
    DocumentType.docx,
    DocumentType.djvu,
  ];

  final Set<DocumentType> types;
  final String query;

  bool get isEmpty => types.isEmpty;

  bool selects(DocumentType type) => types.contains(type);

  bool matches(DocumentType type) => types.isEmpty || types.contains(type);

  DocumentFilter toggle(DocumentType type) => selects(type)
      ? DocumentFilter(types.difference({type}), query)
      : DocumentFilter(types.union({type}), query);

  DocumentFilter withQuery(String query) => DocumentFilter(types, query);

  DocumentFilter clear() => DocumentFilter(const {}, query);
}
