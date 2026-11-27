import 'dart:ui';

import 'package:flutter/widgets.dart';

import '../theme/app_tokens.dart';

enum AppBarEdge { top, bottom }

class AppBarSurface extends StatelessWidget {
  const AppBarSurface({
    required this.child,
    this.solid,
    this.divider,
    this.showDivider = true,
    super.key,
  });

  final Widget child;
  final Color? solid;
  final AppBarEdge? divider;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final palette = tokens.palette;
    final glass = tokens.graphics.blur;
    final edge = divider;
    final side = BorderSide(
      color: showDivider ? palette.rule : const Color(0x00000000),
    );
    final decorated = AnimatedContainer(
      duration: tokens.motion.quick,
      decoration: BoxDecoration(
        color: glass ? palette.glass : (solid ?? palette.sheet),
        border: switch (edge) {
          AppBarEdge.top => Border(top: side),
          AppBarEdge.bottom => Border(bottom: side),
          null => null,
        },
      ),
      child: child,
    );

    if (!glass) return decorated;

    final sigma = tokens.blur.glass;
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
        child: decorated,
      ),
    );
  }
}
