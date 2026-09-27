import 'package:pdfrx/pdfrx.dart';
import 'package:reader_documents/features/documents/data/document_rect.dart';

extension PdfRectMapping on PdfRect {
  DocumentRect toDocumentRect() => DocumentRect(left, top, right, bottom);
}

extension DocumentRectMapping on DocumentRect {
  PdfRect toPdfRect() => PdfRect(left, top, right, bottom);
}
