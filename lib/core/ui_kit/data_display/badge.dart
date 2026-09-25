import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

import '../tokens/app_radius.dart';

enum AppBadgeVariant { primary, secondary, outline, destructive, blur }

class AppBadge extends StatelessWidget {
  const AppBadge({
    required this.child,
    this.variant = AppBadgeVariant.primary,
    super.key,
  });

  final Widget child;
  final AppBadgeVariant variant;

  @override
  Widget build(BuildContext context) {
    if (variant != AppBadgeVariant.blur) {
      return FBadge(
        variant: switch (variant) {
          AppBadgeVariant.primary => FBadgeVariant.primary,
          AppBadgeVariant.secondary => FBadgeVariant.secondary,
          AppBadgeVariant.outline => FBadgeVariant.outline,
          AppBadgeVariant.destructive => FBadgeVariant.destructive,
          AppBadgeVariant.blur => throw StateError('unreachable'),
        },
        child: child,
      );
    }

    final colors = context.theme.colors;
    final baseStyle = context.theme.badgeStyles.secondary;
    final radius = AppRadius.of(context).pill;
    return IntrinsicWidth(
      child: IntrinsicHeight(
        child: ClipRRect(
          borderRadius: radius,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: colors.secondary.withValues(alpha: 0.7),
                borderRadius: radius,
              ),
              child: Center(
                child: Padding(
                  padding: baseStyle.padding,
                  child: DefaultTextStyle.merge(
                    style: baseStyle.labelTextStyle,
                    child: child,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
