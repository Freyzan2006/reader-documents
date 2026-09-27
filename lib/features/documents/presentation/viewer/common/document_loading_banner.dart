import 'package:flutter/widgets.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';

class DocumentLoadingBanner extends StatelessWidget {
  const DocumentLoadingBanner({super.key});

  static const _skeletonPageCount = 3;
  static const _skeletonPageOffset = 10.0;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: AspectRatio(
        aspectRatio: 1 / 1.4,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maxOffset = _skeletonPageOffset * (_skeletonPageCount - 1);
            final pageWidth = constraints.maxWidth - maxOffset;
            final pageHeight = constraints.maxHeight - maxOffset;

            return Stack(
              children: [
                for (var i = 0; i < _skeletonPageCount; i++)
                  Positioned(
                    left: i * _skeletonPageOffset,
                    top: i * _skeletonPageOffset,
                    width: pageWidth,
                    height: pageHeight,
                    child: AppSkeleton(width: pageWidth, height: pageHeight),
                  ),
              ],
            );
          },
        ),
      ),
    ),
  );
}
