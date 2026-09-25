import 'package:reader_documents/features/documents/data/document_file.dart';

class DocumentFilter {
  const DocumentFilter([this.types = const {}]);

  static const selectable = [
    DocumentType.pdf,
    DocumentType.docx,
    DocumentType.djvu,
  ];

  final Set<DocumentType> types;

  bool get isEmpty => types.isEmpty;

  bool selects(DocumentType type) => types.contains(type);

  bool matches(DocumentType type) => types.isEmpty || types.contains(type);

  DocumentFilter toggle(DocumentType type) => selects(type)
      ? DocumentFilter(types.difference({type}))
      : DocumentFilter(types.union({type}));

  DocumentFilter clear() => const DocumentFilter();
}
