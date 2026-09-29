import 'package:flutter/widgets.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';
import 'package:reader_documents/features/documents/data/models/document_file.dart';

/// A document's file-type glyph — a bundled PNG for the formats that have
/// one, falling back to a generic file icon for the rest.
///
/// The PNGs are flat black glyphs, so they're tinted to the ambient icon
/// color via [Image.asset]'s `color`/`colorBlendMode` (the same technique
/// [Icon] uses internally) — otherwise they'd stay solid black regardless of
/// theme, disappearing against a dark card in dark mode.
class DocumentIcon extends StatelessWidget {
  const DocumentIcon({required this.type, this.size = 20, super.key});

  final DocumentType type;
  final double size;

  static const _assetByType = {
    DocumentType.pdf: 'assets/pdf.png',
    DocumentType.docx: 'assets/docx.png',
  };

  @override
  Widget build(BuildContext context) {
    final asset = _assetByType[type];
    if (asset == null) return Icon(AppIcons.fileText, size: size);

    final color =
        IconTheme.of(context).color ?? AppColors.of(context).foreground;
    return Image.asset(
      asset,
      width: size,
      height: size,
      color: color,
      colorBlendMode: BlendMode.srcIn,
    );
  }
}
