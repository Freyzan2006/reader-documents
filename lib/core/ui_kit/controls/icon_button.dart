import 'package:flutter/widgets.dart';

import '../primitives/tappable.dart';
import '../theme/app_tokens.dart';
import '../tokens/app_palette.dart';
import '../tokens/app_radius.dart';

enum AppIconButtonVariant {
  ghost,
  filled,
  inverse;

  Color fill(AppPalette palette, {required bool pressed}) => switch (this) {
    ghost => pressed ? palette.shadeStrong : const Color(0x00000000),
    filled => pressed ? palette.shadeStrong : palette.shade,
    inverse => palette.ink,
  };

  Color foreground(AppPalette palette) =>
      this == inverse ? palette.onInk : palette.ink;
}

class AppIconButton extends StatelessWidget {
  const AppIconButton({
    required this.icon,
    required this.onPressed,
    this.variant = AppIconButtonVariant.ghost,
    this.color,
    this.enabled,
    this.semanticsLabel,
    super.key,
  });

  static const _size = 40.0;
  static const _iconSize = 20.0;
  static const _disabledOpacity = 0.38;

  final IconData icon;
  final VoidCallback? onPressed;
  final AppIconButtonVariant variant;
  final String? semanticsLabel;
  final Color? color;
  final bool? enabled;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final palette = tokens.palette;
    final active = enabled ?? onPressed != null;

    return AppTappable.builder(
      onPressed: active ? onPressed : null,
      semanticsLabel: semanticsLabel,
      builder: (context, state) => Opacity(
        opacity: active ? 1 : _disabledOpacity,
        child: AppFocusRing(
          visible: state.focused,
          borderRadius: AppRadii.pill,
          child: AnimatedContainer(
            duration: tokens.motion.quick,
            width: _size,
            height: _size,
            decoration: BoxDecoration(
              color: variant.fill(palette, pressed: state.pressed),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: _iconSize,
              color: color ?? variant.foreground(palette),
            ),
          ),
        ),
      ),
    );
  }
}
