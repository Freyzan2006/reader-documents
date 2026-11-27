import 'package:flutter/widgets.dart';

import '../tokens/app_palette.dart';
import '../tokens/app_typography.dart';
import 'app_tokens.dart';
import 'graphics_mode.dart';

class AppTheme extends StatelessWidget {
  const AppTheme({required this.tokens, required this.child, super.key});

  static const _iconSize = 20.0;

  final AppTokens tokens;
  final Widget child;

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<AppPalette>(
    tween: _AppPaletteTween(end: tokens.palette),
    duration: tokens.motion.paletteChange,
    curve: AppMotion.curve,
    child: child,
    builder: (context, palette, child) => AppThemeScope(
      tokens: tokens.copyWith(palette: palette),
      child: DefaultTextStyle(
        style: AppTextStyles.body.copyWith(color: palette.ink),
        child: IconTheme(
          data: IconThemeData(color: palette.ink, size: _iconSize),
          child: DefaultSelectionStyle(
            cursorColor: palette.ink,
            selectionColor: palette.ink.withValues(alpha: 0.2),
            child: child!,
          ),
        ),
      ),
    ),
  );
}

class _AppPaletteTween extends Tween<AppPalette> {
  _AppPaletteTween({super.end});

  @override
  AppPalette lerp(double t) => AppPalette.lerp(begin ?? end!, end!, t);
}
