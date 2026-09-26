import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';

class PdfMagnifier extends StatelessWidget {
  const PdfMagnifier({
    required this.content,
    required this.contentSize,
    super.key,
  });

  static const _targetSize = 96.0;
  static const _frameColor = Color(0xFF1A1A1A);

  // Inverts RGB so light document pages read as light text on a dark frame,
  // without needing to distinguish text pixels from background pixels.
  static const _invertColorFilter = ColorFilter.matrix([
    -1,
    0,
    0,
    0,
    255,
    0,
    -1,
    0,
    0,
    255,
    0,
    0,
    -1,
    0,
    255,
    0,
    0,
    0,
    1,
    0,
  ]);

  final Widget content;
  final Size contentSize;

  @override
  Widget build(BuildContext context) {
    final radius = AppRadius.of(context).lg;
    final scale = _targetSize / math.min(contentSize.width, contentSize.height);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: _frameColor,
        borderRadius: radius,
        border: Border.all(color: AppColors.accent(context), width: 2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xs),
        child: ClipRRect(
          borderRadius: AppRadius.of(context).md,
          child: SizedBox(
            width: contentSize.width * scale,
            height: contentSize.height * scale,
            child: ColorFiltered(
              colorFilter: _invertColorFilter,
              child: content,
            ),
          ),
        ),
      ),
    );
  }
}
