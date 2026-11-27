import 'package:flutter/widgets.dart';

import '../primitives/frosted_surface.dart';
import '../theme/app_tokens.dart';
import '../tokens/app_palette.dart';
import '../tokens/app_radius.dart';
import '../tokens/app_typography.dart';

enum AppBadgeVariant {
  primary,
  secondary,
  outline,
  danger,
  blur;

  Color fill(AppPalette palette) => switch (this) {
    primary => palette.ink,
    secondary || blur => palette.shade,
    outline => palette.sheet,
    danger => palette.danger,
  };

  Color foreground(AppPalette palette) => switch (this) {
    primary => palette.onInk,
    secondary || outline || blur => palette.ink,
    danger => palette.onDanger,
  };
}

final class AppContrast {
  const AppContrast._();

  static const _dark = Color(0xFF111111);
  static const _light = Color(0xFFFFFFFF);

  static Color on(Color background) =>
      background.computeLuminance() > 0.5 ? _dark : _light;
}

class AppBadge extends StatelessWidget {
  const AppBadge({
    required this.child,
    this.variant = AppBadgeVariant.primary,
    this.color,
    super.key,
  });

  static const _padding = EdgeInsets.symmetric(horizontal: 6, vertical: 1);

  final Widget child;
  final AppBadgeVariant variant;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final palette = context.tokens.palette;
    final custom = color;
    final fill = custom ?? variant.fill(palette);
    final foreground = custom == null
        ? variant.foreground(palette)
        : AppContrast.on(custom);
    final label = Padding(
      padding: _padding,
      child: DefaultTextStyle.merge(
        style: AppTextStyles.meta.copyWith(color: foreground),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        child: IconTheme.merge(
          data: IconThemeData(color: foreground, size: 12),
          child: child,
        ),
      ),
    );

    if (variant == AppBadgeVariant.blur && custom == null) {
      return IntrinsicWidth(
        child: AppFrostedSurface(
          color: fill,
          borderRadius: AppRadii.xs,
          child: label,
        ),
      );
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: fill,
        borderRadius: AppRadii.xs,
        border: variant == AppBadgeVariant.outline && custom == null
            ? Border.all(color: palette.ruleStrong)
            : null,
      ),
      child: label,
    );
  }
}
