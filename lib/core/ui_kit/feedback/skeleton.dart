import 'package:flutter/widgets.dart';

import '../tokens/app_radius.dart';
import '../tokens/app_spacing.dart';
import '../theme/app_tokens.dart';

class AppPulse extends StatefulWidget {
  const AppPulse({required this.child, this.minOpacity = 0.45, super.key});

  final Widget child;
  final double minOpacity;

  @override
  State<AppPulse> createState() => _AppPulseState();
}

class _AppPulseState extends State<AppPulse>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
    value: 1,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final animate = context.tokens.motion.loops;
    if (animate && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!animate && _controller.isAnimating) {
      _controller
        ..stop()
        ..value = 1;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: _controller.drive(Tween(begin: widget.minOpacity, end: 1.0)),
    child: widget.child,
  );
}

class AppSkeleton extends StatelessWidget {
  const AppSkeleton({this.width, this.height = 16, super.key})
    : shape = BoxShape.rectangle;

  const AppSkeleton.circle({required double size, super.key})
    : width = size,
      height = size,
      shape = BoxShape.circle;

  final double? width;
  final double height;
  final BoxShape shape;

  @override
  Widget build(BuildContext context) => AppPulse(
    child: Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: context.tokens.palette.shade,
        shape: shape,
        borderRadius: shape == BoxShape.circle ? null : AppRadii.sm,
      ),
    ),
  );
}

class AppSkeletonText extends StatelessWidget {
  const AppSkeletonText({
    this.lines = 3,
    this.lineHeight = 12,
    this.spacing = AppSpacing.sm,
    this.lastLineWidthFactor = 0.6,
    super.key,
  });

  final int lines;
  final double lineHeight;
  final double spacing;
  final double lastLineWidthFactor;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: spacing,
      children: [
        for (var i = 0; i < lines; i++)
          AppSkeleton(
            height: lineHeight,
            width: i == lines - 1
                ? constraints.maxWidth * lastLineWidthFactor
                : constraints.maxWidth,
          ),
      ],
    ),
  );
}
