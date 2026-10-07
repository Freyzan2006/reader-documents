import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

import '../primitives/frosted_surface.dart';
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
    this.color,
    super.key,
  });

  final Widget child;
  final AppBadgeVariant variant;

  /// An arbitrary background color, overriding [variant] entirely. The
  /// label color is picked automatically for contrast. Use this for
  /// user-chosen colors (e.g. tag colors) that don't fit a fixed semantic
  /// variant.
  final Color? color;

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
    final customColor = color;
    if (customColor != null) {
      final foreground = customColor.computeLuminance() > 0.5
          ? const Color(0xFF0A0A0A)
          : const Color(0xFFFFFFFF);
      final base = context.theme.badgeStyles.secondary;
      return FBadge(
        style: FBadgeStyle(
          decoration: ShapeDecoration(
            shape: RoundedSuperellipseBorder(
              borderRadius: AppRadius.of(context).pill,
            ),
            color: customColor,
          ),
          labelTextStyle: base.labelTextStyle.copyWith(color: foreground),
          padding: base.padding,
        ),
        child: child,
      );
    }

    final custom = _customColors(context, variant);
    if (custom != null) {
      final (variantColor, foreground) = custom;
      final base = context.theme.badgeStyles.secondary;
      return FBadge(
        style: FBadgeStyle(
          decoration: ShapeDecoration(
            shape: RoundedSuperellipseBorder(
              borderRadius: AppRadius.of(context).pill,
            ),
            color: variantColor,
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

    final baseStyle = context.theme.badgeStyles.secondary;
    return IntrinsicWidth(
      child: IntrinsicHeight(
        child: AppFrostedSurface(
          color: context.theme.colors.secondary,
          borderRadius: AppRadius.of(context).pill,
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
    );
  }
}
