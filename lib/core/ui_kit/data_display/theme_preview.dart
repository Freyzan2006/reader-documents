import 'package:flutter/widgets.dart';

import '../theme/app_tokens.dart';
import '../tokens/app_palette.dart';
import '../tokens/app_radius.dart';

class AppThemePreview extends StatelessWidget {
  const AppThemePreview({required this.brightnesses, super.key});

  final List<Brightness> brightnesses;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: AppRadii.sm,
    child: DecoratedBox(
      position: DecorationPosition.foreground,
      decoration: BoxDecoration(
        borderRadius: AppRadii.sm,
        border: Border.all(color: context.tokens.palette.rule),
      ),
      child: switch (brightnesses) {
        [final single] => _Pane(brightness: single),
        [final first, final second, ...] => Stack(
          fit: StackFit.expand,
          children: [
            _Pane(brightness: first),
            ClipPath(
              clipper: const _LowerTriangle(),
              child: _Pane(brightness: second),
            ),
            CustomPaint(
              painter: _Diagonal(color: context.tokens.palette.ruleStrong),
            ),
          ],
        ),
        _ => const SizedBox.shrink(),
      },
    ),
  );
}

class _LowerTriangle extends CustomClipper<Path> {
  const _LowerTriangle();

  @override
  Path getClip(Size size) => Path()
    ..moveTo(size.width, 0)
    ..lineTo(size.width, size.height)
    ..lineTo(0, size.height)
    ..close();

  @override
  bool shouldReclip(_LowerTriangle oldClipper) => false;
}

class _Diagonal extends CustomPainter {
  const _Diagonal({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) => canvas.drawLine(
    Offset(size.width, 0),
    Offset(0, size.height),
    Paint()
      ..color = color
      ..strokeWidth = 1,
  );

  @override
  bool shouldRepaint(_Diagonal oldDelegate) => oldDelegate.color != color;
}

class _Pane extends StatelessWidget {
  const _Pane({required this.brightness});

  final Brightness brightness;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(brightness, context.tokens.palette.family);
    return ColoredBox(
      color: palette.paper,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final unit = constraints.maxWidth / 24;
          return Stack(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(
                  unit * 2.2,
                  unit * 2.4,
                  unit * 2.2,
                  0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: unit * 1.2,
                  children: [
                    _Bar(
                      width: unit * 10,
                      height: unit * 1.8,
                      color: palette.ink,
                    ),
                    _Bar(
                      width: unit * 6,
                      height: unit * 0.8,
                      color: palette.ink3,
                    ),
                    _Bar(height: unit * 2.4, color: palette.shade, round: true),
                    Row(
                      spacing: unit * 1.2,
                      children: [
                        Expanded(
                          child: _Sheet(
                            palette: palette,
                            unit: unit,
                            read: true,
                          ),
                        ),
                        Expanded(
                          child: _Sheet(palette: palette, unit: unit),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: unit * 4.4,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: palette.sheet,
                    border: Border(top: BorderSide(color: palette.rule)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _Bar(
                        width: unit * 4,
                        height: unit * 1.9,
                        color: palette.ink,
                        round: true,
                      ),
                      _Bar(
                        width: unit * 1.6,
                        height: unit * 1.6,
                        color: palette.ink3,
                      ),
                      _Bar(
                        width: unit * 1.6,
                        height: unit * 1.6,
                        color: palette.ink3,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Sheet extends StatelessWidget {
  const _Sheet({required this.palette, required this.unit, this.read = false});

  final AppPalette palette;
  final double unit;
  final bool read;

  @override
  Widget build(BuildContext context) => AspectRatio(
    aspectRatio: 1 / 1.414,
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: palette.sheet,
        borderRadius: BorderRadius.circular(unit * 0.5),
        border: Border.all(color: palette.rule),
      ),
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.all(unit * 1.2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: unit * 0.6,
              children: [
                for (final factor in const [0.6, 1.0, 1.0, 0.5])
                  FractionallySizedBox(
                    widthFactor: factor,
                    child: _Bar(height: unit * 0.5, color: palette.shadeStrong),
                  ),
              ],
            ),
          ),
          if (read)
            Positioned(
              left: 0,
              bottom: 0,
              width: unit * 4,
              height: unit * 0.5,
              child: ColoredBox(color: palette.ink),
            ),
        ],
      ),
    ),
  );
}

class _Bar extends StatelessWidget {
  const _Bar({
    required this.height,
    required this.color,
    this.width,
    this.round = false,
  });

  final double? width;
  final double height;
  final Color color;
  final bool round;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: width,
    height: height,
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(round ? height / 2 : height / 4),
      ),
    ),
  );
}
