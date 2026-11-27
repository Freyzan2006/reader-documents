import 'package:flutter/widgets.dart';

import '../primitives/frosted_surface.dart';
import '../theme/app_tokens.dart';
import '../tokens/app_borders.dart';
import '../tokens/app_radius.dart';
import '../tokens/app_spacing.dart';

enum AppCardVariant { standard, blur }

class AppCard extends StatelessWidget {
  const AppCard({
    required this.child,
    this.padding,
    this.variant = AppCardVariant.standard,
    super.key,
  });

  static const defaultPadding = EdgeInsets.all(AppSpacing.lg);

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final AppCardVariant variant;

  @override
  Widget build(BuildContext context) {
    final content = Padding(padding: padding ?? defaultPadding, child: child);

    return switch (variant) {
      AppCardVariant.standard => DecoratedBox(
        decoration: BoxDecoration(
          color: context.tokens.palette.sheet,
          borderRadius: AppRadii.md,
          border: AppBorders.all(context),
        ),
        child: content,
      ),
      AppCardVariant.blur => AppFrostedSurface(
        color: context.tokens.palette.sheet,
        borderRadius: AppRadii.md,
        border: AppBorders.all(context),
        child: content,
      ),
    };
  }
}
