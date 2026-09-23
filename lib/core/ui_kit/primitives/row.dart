import 'package:flutter/widgets.dart';

import '../tokens/app_spacing.dart';

/// A horizontal layout, like [Row], but with a spacing default from
/// [AppSpacing] instead of `0` — most rows in this app want *some* gap
/// between children.
class AppRow extends StatelessWidget {
  const AppRow({
    required this.children,
    this.spacing = AppSpacing.sm,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.mainAxisSize = MainAxisSize.max,
    super.key,
  });

  final List<Widget> children;
  final double spacing;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisSize mainAxisSize;

  @override
  Widget build(BuildContext context) => Row(
    spacing: spacing,
    mainAxisAlignment: mainAxisAlignment,
    crossAxisAlignment: crossAxisAlignment,
    mainAxisSize: mainAxisSize,
    children: children,
  );
}
