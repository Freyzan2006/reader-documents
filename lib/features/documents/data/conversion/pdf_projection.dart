import '../models/document_file.dart';

/// A read-only PDF rendering of a non-PDF document. A future editor changes
/// the source document and asks for a fresh projection; it never edits this.
abstract interface class PdfProjection {
  /// Path of a PDF that renders [file].
  Future<String> pdfPathFor(DocumentFile file);
}
