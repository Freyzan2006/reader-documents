import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

import '../tokens/app_colors.dart';
import '../tokens/app_radius.dart';

enum AppBadgeVariant {
  primary,
  secondary,
  outline,
  destructive,
  blur,
  success,
  accent,
  warning,
}

class AppBadge extends StatelessWidget {
  const AppBadge({
    required this.child,
    this.variant = AppBadgeVariant.primary,
    super.key,
  });

  final Widget child;
  final AppBadgeVariant variant;

  static (Color, Color)? _customColors(
    BuildContext context,
    AppBadgeVariant variant,
  ) => switch (variant) {
    AppBadgeVariant.success => (
      AppColors.success(context),
      AppColors.successForeground(context),
    ),
    AppBadgeVariant.accent => (
      AppColors.accent(context),
      AppColors.accentForeground(context),
    ),
    AppBadgeVariant.warning => (
      AppColors.warning(context),
      AppColors.warningForeground(context),
    ),
    _ => null,
  };

  @override
  Widget build(BuildContext context) {
    final custom = _customColors(context, variant);
    if (custom != null) {
      final (color, foreground) = custom;
      final base = context.theme.badgeStyles.secondary;
      return FBadge(
        style: FBadgeStyle(
          decoration: ShapeDecoration(
            shape: RoundedSuperellipseBorder(
              borderRadius: AppRadius.of(context).pill,
            ),
            color: color,
          ),
          labelTextStyle: base.labelTextStyle.copyWith(color: foreground),
          padding: base.padding,
        ),
        child: child,
      );
    }

    if (variant != AppBadgeVariant.blur) {
      return FBadge(
        variant: switch (variant) {
          AppBadgeVariant.primary => FBadgeVariant.primary,
          AppBadgeVariant.secondary => FBadgeVariant.secondary,
          AppBadgeVariant.outline => FBadgeVariant.outline,
          AppBadgeVariant.destructive => FBadgeVariant.destructive,
          AppBadgeVariant.blur ||
          AppBadgeVariant.success ||
          AppBadgeVariant.accent ||
          AppBadgeVariant.warning => throw StateError('unreachable'),
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
