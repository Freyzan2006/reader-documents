import 'dart:async';

import 'package:flutter/widgets.dart';

import '../theme/app_tokens.dart';
import '../theme/graphics_mode.dart';

class AppPop extends StatefulWidget {
  const AppPop({required this.active, required this.child, super.key});

  static const _from = 0.6;
  static const _peak = 1.25;

  final bool active;
  final Widget child;

  @override
  State<AppPop> createState() => _AppPopState();
}

class _AppPopState extends State<AppPop> with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  Animation<double>? _scale;

  void _pop(Duration duration) {
    final controller =
        _controller ?? AnimationController(vsync: this, duration: duration);
    if (_controller == null) {
      _controller = controller;
      _scale = TweenSequence([
        TweenSequenceItem(
          tween: Tween(begin: AppPop._from, end: AppPop._peak),
          weight: 45,
        ),
        TweenSequenceItem(
          tween: Tween(
            begin: AppPop._peak,
            end: 1.0,
          ).chain(CurveTween(curve: AppMotion.curve)),
          weight: 55,
        ),
      ]).animate(controller);
    }
    controller
      ..duration = duration
      ..forward(from: 0);
  }

  @override
  void didUpdateWidget(AppPop oldWidget) {
    super.didUpdateWidget(oldWidget);
    final motion = context.tokens.motion;
    if (widget.active && !oldWidget.active && motion.scale) {
      setState(() => _pop(motion.emphasis));
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ScaleTransition(
    scale: _scale ?? kAlwaysCompleteAnimation,
    child: widget.child,
  );
}

class AppEntrance extends StatefulWidget {
  const AppEntrance({required this.index, required this.child, super.key});

  static const _rise = 8.0;

  final int index;
  final Widget child;

  @override
  State<AppEntrance> createState() => _AppEntranceState();
}

class _AppEntranceState extends State<AppEntrance>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  Animation<double>? _progress;
  Timer? _delay;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_controller != null) return;
    final motion = context.tokens.motion;
    final delay = motion.staggerDelay(widget.index);
    if (delay == null) return;
    final controller = AnimationController(vsync: this, duration: motion.quick);
    _controller = controller;
    _progress = controller.drive(CurveTween(curve: AppMotion.curve));
    _delay = Timer(delay, controller.forward);
  }

  @override
  void dispose() {
    _delay?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = _progress;
    if (progress == null) return widget.child;
    return FadeTransition(
      opacity: progress,
      child: AnimatedBuilder(
        animation: progress,
        builder: (context, child) => Transform.translate(
          offset: Offset(0, AppEntrance._rise * (1 - progress.value)),
          child: child,
        ),
        child: widget.child,
      ),
    );
  }
}

class AppPageRoute<T> extends PageRoute<T> {
  AppPageRoute({required this.builder, super.settings});

  static const _enterOffset = 28.0;
  static const _leaveOffset = 14.0;
  static final _curve = CurveTween(curve: AppMotion.curve);

  final WidgetBuilder builder;

  AppMotion get _motion {
    final context = navigator?.context;
    return context == null ? AppMotion.reduced : context.tokens.motion;
  }

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  bool get opaque => true;

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => _motion.route;

  @override
  Duration get reverseTransitionDuration => _motion.routeExit;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) => Builder(builder: builder);

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final enter = _curve.transform(animation.value);
    final faded = Opacity(opacity: enter, child: child);
    if (!context.tokens.motion.slide) return faded;
    final leave = _curve.transform(secondaryAnimation.value);
    return Transform.translate(
      offset: Offset(_enterOffset * (1 - enter) - _leaveOffset * leave, 0),
      child: faded,
    );
  }
}

class AppReveal extends StatelessWidget {
  const AppReveal({required this.visible, required this.child, super.key});

  final bool visible;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final duration = context.tokens.motion.reveal;
    final opacity = visible ? 1.0 : 0.0;
    if (duration == Duration.zero) {
      return Opacity(opacity: opacity, child: child);
    }
    return AnimatedOpacity(
      opacity: opacity,
      duration: duration,
      curve: AppMotion.curve,
      child: child,
    );
  }
}

class AppHero extends StatelessWidget {
  const AppHero({required this.tag, required this.child, super.key});

  final Object? tag;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final tag = this.tag;
    if (tag == null || !context.tokens.motion.hero) return child;
    return Hero(tag: tag, child: child);
  }
}
