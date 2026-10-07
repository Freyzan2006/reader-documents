import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

import '../theme/app_effects.dart';

enum AppBarrierVariant { standard, blur }

abstract final class AppBarrier {
  static const _sigma = 5.0;

  static AppBarrierVariant resolve(
    BuildContext context,
    AppBarrierVariant? variant,
  ) =>
      variant ??
      (AppEffects.blurOf(context)
          ? AppBarrierVariant.blur
          : AppBarrierVariant.standard);

  static Color tint(BuildContext context, double animation) {
    final barrier = context.theme.colors.barrier;
    return barrier.withValues(alpha: barrier.a * animation);
  }

  static ImageFilter Function(BuildContext, double) filter(
    AppBarrierVariant variant,
  ) => (context, animation) {
    final tinted = ColorFilter.mode(
      tint(context, animation),
      BlendMode.srcOver,
    );
    return switch (variant) {
      AppBarrierVariant.standard => tinted,
      AppBarrierVariant.blur => ImageFilter.compose(
        outer: ImageFilter.blur(
          sigmaX: _sigma * animation,
          sigmaY: _sigma * animation,
        ),
        inner: tinted,
      ),
    };
  };
}

class AppBarrierLayer extends StatelessWidget {
  const AppBarrierLayer({
    required this.variant,
    required this.animation,
    this.onTap,
    super.key,
  });

  final AppBarrierVariant variant;
  final double animation;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tinted = GestureDetector(
      onTap: onTap,
      child: ColoredBox(color: AppBarrier.tint(context, animation)),
    );

    return IgnorePointer(
      ignoring: animation == 0,
      child: switch (variant) {
        AppBarrierVariant.standard => tinted,
        AppBarrierVariant.blur => BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: AppBarrier._sigma * animation,
            sigmaY: AppBarrier._sigma * animation,
          ),
          child: tinted,
        ),
      },
    );
  }
}
