import 'package:flutter/widgets.dart';

import '../tokens/app_breakpoints.dart';
import '../tokens/app_spacing.dart';

/// A non-scrolling, responsive column grid.
///
/// For scrollable grids (e.g. document thumbnails), prefer Flutter's own
/// `GridView` with `SliverGridDelegateWithMaxCrossAxisExtent` — it already
/// computes column count from available width natively. `AppGrid` fills the
/// gap Flutter and Forui both leave open: laying out a fixed list of children
/// into responsive columns *inline*, without scrolling — e.g. a settings
/// page's cards.
class AppGrid extends StatelessWidget {
  const AppGrid({required this.children, this.spacing = AppSpacing.md, this.runSpacing = AppSpacing.md, super.key});

  final List<Widget> children;
  final double spacing;
  final double runSpacing;

  static int _columnsFor(ScreenSize size) => switch (size) {
    ScreenSize.mobile => 1,
    ScreenSize.tablet => 2,
    ScreenSize.desktop => 3,
  };

  @override
  Widget build(BuildContext context) {
    final columns = _columnsFor(context.screenSize);
    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = (constraints.maxWidth - spacing * (columns - 1)) / columns;
        return Wrap(
          spacing: spacing,
          runSpacing: runSpacing,
          children: [for (final child in children) SizedBox(width: itemWidth, child: child)],
        );
      },
    );
  }
}
