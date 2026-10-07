import 'dart:ui';

import 'package:flutter/widgets.dart';

import '../theme/app_effects.dart';

class AppFrostedSurface extends StatelessWidget {
  const AppFrostedSurface({
    required this.color,
    required this.borderRadius,
    required this.child,
    this.frosted = true,
    this.border,
    super.key,
  });

  static const _sigma = 20.0;
  static const _translucency = 0.7;

  final Color color;
  final BorderRadius borderRadius;
  final bool frosted;
  final BoxBorder? border;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final blur = frosted && AppEffects.blurOf(context);
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
              filter: ImageFilter.blur(sigmaX: _sigma, sigmaY: _sigma),
              child: surface,
            )
          : surface,
    );
  }
}
