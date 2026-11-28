import 'package:flutter/widgets.dart';
import 'package:reader_documents/features/documents/data/conversion/pdf_projection.dart';

import '../common/document_loading_overlay.dart';
import '../contract/document_viewer.dart';
import '../pdf/pdf_document_viewer.dart';

/// Only the path is swapped for the projected PDF; the original type stays for
/// titles, hero tags and highlights.
class ConvertedPdfDocumentViewer extends DocumentViewer {
  const ConvertedPdfDocumentViewer({
    required super.file,
    required super.initialPageNumber,
    required super.highlights,
    required super.onPageChanged,
    required super.onReady,
    required super.onBackgroundTap,
    required super.passwordProvider,
    required super.buildContextMenu,
    required super.buildMagnifier,
    required super.buildErrorBanner,
    required super.buildLoadingBanner,
    required this.projection,
    super.key,
  });

  final PdfProjection projection;

  @override
  State<ConvertedPdfDocumentViewer> createState() =>
      _ConvertedPdfDocumentViewerState();
}

class _ConvertedPdfDocumentViewerState
    extends State<ConvertedPdfDocumentViewer> {
  late Future<String> _pdfPath;

  @override
  void initState() {
    super.initState();
    _pdfPath = widget.projection.pdfPathFor(widget.file);
  }

  @override
  void didUpdateWidget(covariant ConvertedPdfDocumentViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.projection != widget.projection ||
        oldWidget.file.path != widget.file.path ||
        oldWidget.file.sizeBytes != widget.file.sizeBytes ||
        oldWidget.file.modifiedAt != widget.file.modifiedAt) {
      _pdfPath = widget.projection.pdfPathFor(widget.file);
    }
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<String>(
    future: _pdfPath,
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return widget.buildErrorBanner(
          context,
          isPasswordProtected: false,
          onBack: () => Navigator.of(context).pop(),
        );
      }
      final pdfPath = snapshot.data;
      if (pdfPath == null) {
        return DocumentLoadingOverlay(
          banner: widget.buildLoadingBanner(context),
        );
      }
      return PdfDocumentViewer(
        key: ValueKey(pdfPath),
        file: widget.file.copyWith(path: pdfPath),
        initialPageNumber: widget.initialPageNumber,
        highlights: widget.highlights,
        onPageChanged: widget.onPageChanged,
        onReady: widget.onReady,
        onBackgroundTap: widget.onBackgroundTap,
        passwordProvider: widget.passwordProvider,
        buildContextMenu: widget.buildContextMenu,
        buildMagnifier: widget.buildMagnifier,
        buildErrorBanner: widget.buildErrorBanner,
        buildLoadingBanner: widget.buildLoadingBanner,
      );
    },
  );
}
