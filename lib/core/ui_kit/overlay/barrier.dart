import 'dart:ui';

import 'package:flutter/widgets.dart';

import '../theme/app_tokens.dart';

enum AppBarrierVariant { standard, blur }

abstract final class AppBarrier {
  static AppBarrierVariant resolve(
    BuildContext context,
    AppBarrierVariant? variant,
  ) =>
      variant ??
      (context.tokens.graphics.blur
          ? AppBarrierVariant.blur
          : AppBarrierVariant.standard);

  static Color tint(BuildContext context, double animation) {
    final tokens = context.tokens;
    final barrier = tokens.graphics.blur
        ? tokens.palette.scrim
        : tokens.palette.scrimSolid;
    return barrier.withValues(alpha: barrier.a * animation);
  }
}

class AppBarrierLayer extends StatelessWidget {
  const AppBarrierLayer({
    required this.variant,
    required this.animation,
    this.onTap,
    this.semanticsLabel,
    super.key,
  });

  final AppBarrierVariant variant;
  final double animation;
  final VoidCallback? onTap;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final sigma = context.tokens.blur.scrim * animation;
    final tinted = Semantics(
      label: semanticsLabel,
      button: onTap != null,
      onTap: onTap,
      child: GestureDetector(
        onTap: onTap,
        excludeFromSemantics: true,
        child: ColoredBox(color: AppBarrier.tint(context, animation)),
      ),
    );

    return IgnorePointer(
      ignoring: animation == 0,
      child: switch (variant) {
        AppBarrierVariant.standard => tinted,
        AppBarrierVariant.blur when sigma > 0 => BackdropFilter(
          filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
          child: tinted,
        ),
        AppBarrierVariant.blur => tinted,
      },
    );
  }
}
