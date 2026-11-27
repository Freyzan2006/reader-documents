import 'package:flutter/widgets.dart';

import '../theme/app_tokens.dart';
import '../theme/graphics_mode.dart';
import 'barrier.dart';

enum AppModalPlacement { center, bottom }

class AppModalRoute<T> extends PopupRoute<T> {
  AppModalRoute({
    required this.builder,
    required this.placement,
    required this.tokens,
    required this.barrier,
    this.dismissible = true,
    this.dismissLabel,
    super.settings,
  });

  final WidgetBuilder builder;
  final AppModalPlacement placement;
  final AppTokens tokens;
  final AppBarrierVariant barrier;
  final bool dismissible;
  final String? dismissLabel;

  @override
  Color? get barrierColor => null;

  @override
  bool get barrierDismissible => false;

  @override
  String? get barrierLabel => dismissLabel;

  @override
  Duration get transitionDuration => tokens.motion.sheet;

  @override
  Duration get reverseTransitionDuration => tokens.motion.exit;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) => AppThemeScope(
    tokens: tokens,
    child: Builder(builder: builder),
  );

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: AppMotion.curve,
      reverseCurve: Curves.easeIn,
    );

    return Stack(
      fit: StackFit.expand,
      children: [
        AnimatedBuilder(
          animation: animation,
          builder: (context, _) => AppBarrierLayer(
            variant: barrier,
            animation: animation.value,
            semanticsLabel: dismissLabel,
            onTap: dismissible ? () => Navigator.of(context).maybePop() : null,
          ),
        ),
        switch (placement) {
          AppModalPlacement.bottom => SlideTransition(
            position: Tween(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
          AppModalPlacement.center => FadeTransition(
            opacity: curved,
            child: tokens.motion.scale
                ? ScaleTransition(
                    scale: Tween(
                      begin: AppMotion.scaleFrom,
                      end: 1.0,
                    ).animate(curved),
                    child: child,
                  )
                : child,
          ),
        },
      ],
    );
  }
}
