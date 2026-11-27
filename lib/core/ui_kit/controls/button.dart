import 'package:flutter/widgets.dart';

import '../primitives/tappable.dart';
import '../theme/app_tokens.dart';
import '../tokens/app_palette.dart';
import '../tokens/app_radius.dart';
import '../tokens/app_typography.dart';

enum AppButtonVariant {
  primary,
  secondary,
  outline,
  ghost,
  danger,
  dangerGhost;

  Color fill(AppPalette palette, {required bool pressed}) => switch (this) {
    primary =>
      pressed ? Color.lerp(palette.ink, palette.ink3, 0.25)! : palette.ink,
    secondary => pressed ? palette.shadeStrong : palette.shade,
    outline => pressed ? palette.shade : palette.sheet,
    ghost || dangerGhost => pressed ? palette.shade : const Color(0x00000000),
    danger =>
      pressed ? Color.lerp(palette.danger, palette.ink, 0.15)! : palette.danger,
  };

  Color foreground(AppPalette palette) => switch (this) {
    primary => palette.onInk,
    secondary || outline || ghost => palette.ink,
    danger => palette.onDanger,
    dangerGhost => palette.danger,
  };

  Color? border(AppPalette palette) =>
      this == outline ? palette.ruleStrong : null;
}

enum AppButtonSize {
  sm(height: 32, padding: 12, fontSize: 13, iconSize: 16),
  md(height: 44, padding: 16, fontSize: 14, iconSize: 18),
  lg(height: 52, padding: 20, fontSize: 15, iconSize: 20);

  const AppButtonSize({
    required this.height,
    required this.padding,
    required this.fontSize,
    required this.iconSize,
  });

  final double height;
  final double padding;
  final double fontSize;
  final double iconSize;
}

class AppButton extends StatelessWidget {
  const AppButton({
    required this.onPressed,
    required this.child,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.md,
    this.mainAxisSize = MainAxisSize.max,
    this.prefix,
    this.flexibleChild = false,
    super.key,
  });

  static const _disabledOpacity = 0.38;

  final VoidCallback? onPressed;
  final Widget child;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final MainAxisSize mainAxisSize;
  final Widget? prefix;
  final bool flexibleChild;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final palette = tokens.palette;
    final foreground = variant.foreground(palette);
    final border = variant.border(palette);
    final label = DefaultTextStyle.merge(
      style: AppTextStyles.label.copyWith(
        fontSize: size.fontSize,
        color: foreground,
      ),
      maxLines: flexibleChild ? 2 : 1,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.center,
      child: child,
    );

    return AppTappable.builder(
      onPressed: onPressed,
      builder: (context, state) => Opacity(
        opacity: state.enabled ? 1 : _disabledOpacity,
        child: AppFocusRing(
          visible: state.focused,
          borderRadius: AppRadii.sm,
          child: AnimatedContainer(
            duration: tokens.motion.quick,
            curve: Curves.easeOut,
            constraints: BoxConstraints(minHeight: size.height),
            padding: EdgeInsets.symmetric(horizontal: size.padding),
            decoration: BoxDecoration(
              color: variant.fill(palette, pressed: state.pressed),
              borderRadius: AppRadii.sm,
              border: border == null ? null : Border.all(color: border),
            ),
            child: IconTheme.merge(
              data: IconThemeData(color: foreground, size: size.iconSize),
              child: Row(
                mainAxisSize: mainAxisSize,
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 8,
                children: [
                  ?prefix,
                  if (flexibleChild) Flexible(child: label) else label,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
