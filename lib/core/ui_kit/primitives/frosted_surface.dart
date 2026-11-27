import 'dart:ui';

import 'package:flutter/widgets.dart';

import '../theme/app_tokens.dart';

class AppFrostedSurface extends StatelessWidget {
  const AppFrostedSurface({
    required this.color,
    required this.borderRadius,
    required this.child,
    this.frosted = true,
    this.border,
    super.key,
  });

  static const _translucency = 0.7;

  final Color color;
  final BorderRadius borderRadius;
  final bool frosted;
  final BoxBorder? border;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final blur = frosted && tokens.graphics.blur;
    final sigma = tokens.blur.glass;
    final surface = DecoratedBox(
      decoration: BoxDecoration(
        color: blur ? color.withValues(alpha: _translucency) : color,
        border: border,
        borderRadius: borderRadius,
      ),
      child: child,
    );

    return ClipRRect(
      borderRadius: borderRadius,
      child: blur
          ? BackdropFilter(
              filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
              child: surface,
            )
          : surface,
    );
  }
}
