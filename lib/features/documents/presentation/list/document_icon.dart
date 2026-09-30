import 'package:flutter/widgets.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';
import 'package:reader_documents/features/documents/data/models/document_file.dart';

/// A document's file-type glyph — a bundled PNG for the formats that have
/// one, falling back to a generic file icon for the rest.
///
/// The PNGs are flat black glyphs, so they're tinted via [Image.asset]'s
/// `color`/`colorBlendMode` — otherwise they'd stay solid black regardless of
/// theme, disappearing against a dark card in dark mode.
///
/// Tinted from [AppColors.foreground] directly, not `IconTheme.of(context)`:
/// Forui's [FCard] (what every call site here sits inside) never sets its own
/// `IconTheme`, so that ambient value is whatever Flutter's generic Material
/// default happens to be — a fixed color with no relationship to this app's
/// actual (Forui-driven) light/dark theme, which is exactly how this icon
/// ended up dark-on-dark in dark mode despite the theme-aware fallback beside
/// it.
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
    final color = AppColors.of(context).foreground;
    if (asset == null) return Icon(AppIcons.fileText, size: size, color: color);

    return Image.asset(
      asset,
      width: size,
      height: size,
      color: color,
      colorBlendMode: BlendMode.srcIn,
    );
  }
}
