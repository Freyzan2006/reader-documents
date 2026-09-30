import 'package:flutter/widgets.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';
import 'package:reader_documents/features/documents/data/models/document_file.dart';
import 'package:reader_documents/features/documents/presentation/list/document_icon.dart';

class DocumentLoadingBanner extends StatelessWidget {
  const DocumentLoadingBanner({this.type, super.key});

  /// The format being loaded, shown as a small badge — omitted (e.g. before
  /// a document's own type is even relevant) simply hides the badge.
  final DocumentType? type;

  static const _skeletonPageCount = 3;
  static const _skeletonPageOffset = 10.0;
  static const _textLines = 4;
  static const _badgeSize = 36.0;

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
            final frontIndex = _skeletonPageCount - 1;
            final type = this.type;

            return Stack(
              children: [
                for (var i = 0; i < _skeletonPageCount; i++)
                  Positioned(
                    left: i * _skeletonPageOffset,
                    top: i * _skeletonPageOffset,
                    width: pageWidth,
                    height: pageHeight,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        boxShadow: AppShadows.floating,
                        color: i == frontIndex
                            ? AppColors.of(context).card
                            : null,
                        borderRadius: i == frontIndex
                            ? AppRadius.of(context).sm
                            : null,
                      ),
                      child: i == frontIndex
                          ? Padding(
                              padding: const EdgeInsets.all(AppSpacing.md),
                              child: const AppSkeletonText(
                                lines: _textLines,
                                lineHeight: 10,
                              ),
                            )
                          : AppSkeleton(width: pageWidth, height: pageHeight),
                    ),
                  ),
                if (type != null)
                  Positioned(
                    right: AppSpacing.sm,
                    bottom: AppSpacing.sm,
                    child: SizedBox(
                      width: _badgeSize,
                      height: _badgeSize,
                      child: ClipOval(
                        child: AppCard(
                          padding: EdgeInsets.zero,
                          child: Center(
                            child: DocumentIcon(
                              type: type,
                              size: _badgeSize * 0.55,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    ),
  );
}
