import 'package:flutter/widgets.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';

/// The loading state for [HomeFavoritesSection] — a row of placeholders
/// matching [DocumentCompactCard]'s fixed footprint.
class HomeFavoritesSkeleton extends StatelessWidget {
  const HomeFavoritesSkeleton({super.key});

  static const _cardWidth = 148.0;
  static const _cardHeight = 152.0;
  static const _count = 3;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    physics: const NeverScrollableScrollPhysics(),
    child: Row(
      spacing: AppSpacing.sm,
      children: [
        for (var i = 0; i < _count; i++)
          const AppSkeleton(width: _cardWidth, height: _cardHeight),
      ],
    ),
  );
}
