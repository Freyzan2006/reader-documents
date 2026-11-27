import 'package:flutter/widgets.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';
import 'package:reader_documents/features/documents/data/models/document_file.dart';

class DocumentLoadingBanner extends StatelessWidget {
  const DocumentLoadingBanner({this.type, this.heroTag, super.key});

  final DocumentType? type;
  final Object? heroTag;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final palette = tokens.palette;
    final type = this.type;
    final top = AppHeader.topInset(context);

    return ColoredBox(
      color: palette.shade,
      child: Stack(
        children: [
          Positioned(
            top: top,
            left: 0,
            right: 0,
            child: const AppProgress(height: 2),
          ),
          Positioned.fill(
            top: top + AppSpacing.sm,
            child: AppPulse(
              minOpacity: 0.6,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  boxShadow: tokens.graphics == GraphicsMode.quality
                      ? tokens.elevation.pop
                      : null,
                ),
                child: AppPageThumbnail(
                  format: type?.label,
                  scanned: type == DocumentType.djvu,
                  borderRadius: BorderRadius.zero,
                  fill: true,
                  heroTag: heroTag,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
