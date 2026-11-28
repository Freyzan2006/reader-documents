import 'package:flutter/widgets.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';
import 'package:reader_documents/features/documents/data/conversion/pdf_projection.dart';
import 'package:reader_documents/features/documents/data/models/document_file.dart';

import 'document_thumbnail_engine.dart';

/// Thumbnails a non-PDF document by projecting it to PDF and handing the
/// result to [pdf].
final class ConvertedPdfThumbnailEngine implements DocumentThumbnailEngine {
  const ConvertedPdfThumbnailEngine({
    required this.type,
    required this.projection,
    required this.pdf,
  });

  final DocumentType type;
  final PdfProjection Function(BuildContext context) projection;
  final DocumentThumbnailEngine pdf;

  @override
  bool supports(DocumentType type) => type == this.type;

  @override
  Widget build(BuildContext context, DocumentFile file, {bool preview = true}) {
    if (!preview) return const _PreviewPlaceholder(compact: true);
    return _ProjectedPreview(
      file: file,
      projection: projection(context),
      pdf: pdf,
    );
  }
}

class _ProjectedPreview extends StatefulWidget {
  const _ProjectedPreview({
    required this.file,
    required this.projection,
    required this.pdf,
  });

  final DocumentFile file;
  final PdfProjection projection;
  final DocumentThumbnailEngine pdf;

  @override
  State<_ProjectedPreview> createState() => _ProjectedPreviewState();
}

class _ProjectedPreviewState extends State<_ProjectedPreview> {
  late final Future<String> _pdfPath = widget.projection.pdfPathFor(
    widget.file,
  );

  @override
  Widget build(BuildContext context) => FutureBuilder<String>(
    future: _pdfPath,
    builder: (context, snapshot) {
      final pdfPath = snapshot.data;
      if (snapshot.hasError) return const _PreviewPlaceholder();
      if (pdfPath == null) return const _PreviewSkeleton();
      // The placeholder shows through while the PDF page loads or if it fails.
      return Stack(
        fit: StackFit.expand,
        children: [
          const _PreviewPlaceholder(),
          widget.pdf.build(context, widget.file.copyWith(path: pdfPath)),
        ],
      );
    },
  );
}

class _PreviewPlaceholder extends StatelessWidget {
  const _PreviewPlaceholder({this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) => _PreviewFrame(
    compact: compact,
    lineColor: context.tokens.palette.ruleStrong,
  );
}

class _PreviewSkeleton extends StatelessWidget {
  const _PreviewSkeleton();

  @override
  Widget build(BuildContext context) =>
      _PreviewFrame(lineColor: context.tokens.palette.shadeStrong);
}

class _PreviewFrame extends StatelessWidget {
  const _PreviewFrame({required this.lineColor, this.compact = false});

  final Color lineColor;
  final bool compact;

  static const _lines = [0.56, 0.86, 0.74, 0.9, 0.62];
  static const _compactLines = [0.72, 0.56];

  @override
  Widget build(BuildContext context) {
    final palette = context.tokens.palette;
    return ColoredBox(
      color: palette.sheet,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final layout = _PreviewLayout.resolve(
            compact: compact,
            maxHeight: constraints.maxHeight,
          );

          return ClipRect(
            child: Padding(
              padding: layout.padding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    AppIcons.fileText,
                    size: layout.iconSize,
                    color: palette.ink3,
                  ),
                  if (layout.visibleLines.isNotEmpty) ...[
                    SizedBox(height: layout.gap),
                    for (final width in layout.visibleLines)
                      Padding(
                        padding: EdgeInsets.only(bottom: layout.lineGap),
                        child: FractionallySizedBox(
                          widthFactor: width,
                          child: Container(
                            height: _PreviewLayout.lineHeight,
                            decoration: BoxDecoration(
                              color: lineColor,
                              borderRadius: BorderRadius.circular(1),
                            ),
                          ),
                        ),
                      ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PreviewLayout {
  const _PreviewLayout({
    required this.padding,
    required this.iconSize,
    required this.gap,
    required this.lineGap,
    required this.visibleLines,
  });

  static const lineHeight = 2.0;

  final EdgeInsets padding;
  final double iconSize;
  final double gap;
  final double lineGap;
  final List<double> visibleLines;

  static _PreviewLayout resolve({
    required bool compact,
    required double maxHeight,
  }) {
    final isCompact = compact || maxHeight < 72;
    final lines = isCompact
        ? _PreviewFrame._compactLines
        : _PreviewFrame._lines;
    final padding = EdgeInsets.fromLTRB(
      10,
      isCompact ? 8 : 12,
      10,
      isCompact ? 6 : 8,
    );
    final iconSize = isCompact ? 12.0 : 14.0;
    final gap = isCompact ? 4.0 : 8.0;
    final lineGap = isCompact ? 3.0 : 4.0;
    final available = maxHeight - padding.vertical - iconSize - gap;
    final count = available <= 0
        ? 0
        : (available / (lineHeight + lineGap)).floor().clamp(0, lines.length);

    return _PreviewLayout(
      padding: padding,
      iconSize: iconSize,
      gap: gap,
      lineGap: lineGap,
      visibleLines: lines.take(count).toList(growable: false),
    );
  }
}
