import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../theme/app_tokens.dart';

enum AppSpinnerSize {
  xs(12),
  sm(16),
  md(20),
  lg(28),
  xl(40);

  const AppSpinnerSize(this.dimension);

  final double dimension;

  double get stroke => dimension < 20 ? 1.75 : 2.5;
}

class AppSpinner extends StatefulWidget {
  const AppSpinner({this.size = AppSpinnerSize.md, this.color, super.key});

  final AppSpinnerSize size;
  final Color? color;

  @override
  State<AppSpinner> createState() => _AppSpinnerState();
}

class _AppSpinnerState extends State<AppSpinner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: widget.size.dimension,
    child: RotationTransition(
      turns: _controller,
      child: CustomPaint(
        painter: _ArcPainter(
          color: widget.color ?? context.tokens.palette.ink2,
          stroke: widget.size.stroke,
        ),
      ),
    ),
  );
}

class _ArcPainter extends CustomPainter {
  const _ArcPainter({required this.color, required this.stroke});

  static const _sweep = math.pi * 1.5;

  final Color color;
  final double stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect.deflate(stroke / 2), 0, _sweep, false, paint);
  }

  @override
  bool shouldRepaint(_ArcPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.stroke != stroke;
}
