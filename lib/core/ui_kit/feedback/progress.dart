import 'package:flutter/widgets.dart';

import '../theme/app_tokens.dart';

class AppProgress extends StatefulWidget {
  const AppProgress({
    this.value,
    this.trackColor,
    this.fillColor,
    this.height = 4,
    super.key,
  });

  final double? value;
  final Color? trackColor;
  final Color? fillColor;
  final double height;

  @override
  State<AppProgress> createState() => _AppProgressState();
}

class _AppProgressState extends State<AppProgress>
    with SingleTickerProviderStateMixin {
  static const _segment = 0.35;
  static const _travel = 1 + 2 * _segment / (1 - _segment);

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(AppProgress oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync();
  }

  void _sync() {
    final indeterminate = widget.value == null;
    final animate = indeterminate && !MediaQuery.disableAnimationsOf(context);
    if (animate && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!animate && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.tokens.palette;
    final radius = BorderRadius.circular(widget.height / 2);
    final fill = widget.fillColor ?? palette.ink;
    final value = widget.value;

    return Semantics(
      value: value == null ? null : '${(value * 100).round()}%',
      child: ClipRRect(
        borderRadius: radius,
        child: SizedBox(
          height: widget.height,
          child: ColoredBox(
            color: widget.trackColor ?? palette.shadeStrong,
            child: value == null
                ? AnimatedBuilder(
                    animation: _controller,
                    builder: (context, _) => FractionallySizedBox(
                      widthFactor: _segment,
                      alignment: Alignment(
                        -_travel + _controller.value * 2 * _travel,
                        0,
                      ),
                      child: ColoredBox(color: fill),
                    ),
                  )
                : FractionallySizedBox(
                    widthFactor: value.clamp(0.0, 1.0),
                    alignment: Alignment.centerLeft,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: fill,
                        borderRadius: radius,
                      ),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
