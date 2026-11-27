import 'package:flutter/widgets.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';

class HomeShelfSkeleton extends StatelessWidget {
  const HomeShelfSkeleton({super.key});

  static const _cardWidth = 112.0;
  static const _cardHeight = 200.0;
  static const _count = 3;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    physics: const NeverScrollableScrollPhysics(),
    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
    child: Row(
      spacing: AppSpacing.md,
      children: [
        for (var i = 0; i < _count; i++)
          const AppSkeleton(width: _cardWidth, height: _cardHeight),
      ],
    ),
  );
}
