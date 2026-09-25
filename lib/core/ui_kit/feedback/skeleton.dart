import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

import '../tokens/app_radius.dart';
import '../tokens/app_spacing.dart';

class AppSkeleton extends StatefulWidget {
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
  State<AppSkeleton> createState() => _AppSkeletonState();
}

class _AppSkeletonState extends State<AppSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: _controller.drive(Tween(begin: 0.4, end: 1.0)),
    child: Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: context.theme.colors.muted,
        shape: widget.shape,
        borderRadius: widget.shape == BoxShape.circle
            ? null
            : AppRadius.of(context).sm,
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
