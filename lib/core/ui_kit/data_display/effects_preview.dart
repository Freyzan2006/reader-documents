import 'package:flutter/widgets.dart';

import '../theme/app_tokens.dart';
import '../theme/graphics_mode.dart';
import '../tokens/app_palette.dart';
import '../tokens/app_radius.dart';

/// A miniature screen showing what a [GraphicsMode] looks like, used to pick
/// the graphics mode.
///
/// [GraphicsMode.quality] draws a translucent header, soft shadows and a
/// motion trail; [GraphicsMode.performance] draws the same screen flat —
/// borders instead of shadows, no trail. Pass both modes to split the preview
/// diagonally (as [AppThemePreview] does for "System"), e.g. for an "auto"
/// mode that the device picks; the second mode gets the lower-right half,
/// where the motion trail sits.
///
/// The preview always draws its effects, whatever mode the app is in, since
/// it illustrates a choice rather than reflecting the current one.
class AppEffectsPreview extends StatelessWidget {
  const AppEffectsPreview({required this.modes, super.key});

  final List<GraphicsMode> modes;

  @override
  Widget build(BuildContext context) {
    final palette = context.tokens.palette;
    return ClipRRect(
      borderRadius: AppRadii.sm,
      child: DecoratedBox(
        position: DecorationPosition.foreground,
        decoration: BoxDecoration(
          borderRadius: AppRadii.sm,
          border: Border.all(color: palette.rule),
        ),
        child: switch (modes) {
          [final single] => _Pane(mode: single, palette: palette),
          [final first, final second, ...] => Stack(
            fit: StackFit.expand,
            children: [
              _Pane(mode: first, palette: palette),
              ClipPath(
                clipper: const _LowerTriangle(),
                child: _Pane(mode: second, palette: palette),
              ),
              CustomPaint(painter: _Diagonal(color: palette.ruleStrong)),
            ],
          ),
          _ => const SizedBox.shrink(),
        },
      ),
    );
  }
}

class _Pane extends StatelessWidget {
  const _Pane({required this.mode, required this.palette});

  final GraphicsMode mode;
  final AppPalette palette;

  bool get _quality => mode == GraphicsMode.quality;

  List<BoxShadow>? _shadow(double unit, {double strength = 1}) => _quality
      ? [
          BoxShadow(
            color: const Color(0xFF000000).withValues(alpha: 0.22 * strength),
            blurRadius: unit * 2.4,
            offset: Offset(0, unit * 0.9),
          ),
        ]
      : null;

  Border? get _border => _quality ? null : Border.all(color: palette.rule);

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: palette.paper,
    child: LayoutBuilder(
      builder: (context, constraints) {
        final unit = constraints.maxWidth / 24;
        final pad = unit * 2.2;
        return Stack(
          children: [
            // A soft glow behind the content: gradients are a quality-only
            // effect, and unlike shadows it stays visible in dark themes.
            if (_quality)
              Positioned(
                left: -unit * 6,
                right: -unit * 2,
                top: unit * 4,
                height: unit * 20,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        palette.ink.withValues(alpha: 0.14),
                        palette.ink.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
              ),
            // Content scrolling under the header.
            Positioned(
              left: pad,
              right: pad,
              top: unit * 7,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: unit * 1.6,
                children: [
                  _card(unit, lines: const [0.6, 1.0, 0.8]),
                  _card(unit, lines: const [0.7, 0.9]),
                ],
              ),
            ),
            // Header: translucent glass in quality, solid sheet otherwise.
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              height: unit * 5.2,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: _quality ? palette.glass : palette.sheet,
                  border: Border(bottom: BorderSide(color: palette.rule)),
                  boxShadow: _shadow(unit, strength: 0.5),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: pad),
                  child: Row(
                    children: [
                      _Bar(
                        width: unit * 8,
                        height: unit * 1.4,
                        color: palette.ink,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // A moving element: with a fading trail in quality.
            Positioned(
              right: pad,
              bottom: unit * 2.6,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: unit * 0.5,
                children: [
                  if (_quality)
                    for (final alpha in const [0.12, 0.25, 0.45])
                      _Dot(
                        size: unit * 2.6,
                        color: palette.ink.withValues(alpha: alpha),
                      ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: _shadow(unit),
                    ),
                    child: _Dot(size: unit * 3.6, color: palette.ink),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    ),
  );

  Widget _card(double unit, {required List<double> lines}) => DecoratedBox(
    decoration: BoxDecoration(
      color: palette.sheet,
      borderRadius: BorderRadius.circular(unit * (_quality ? 1.2 : 0.6)),
      border: _border,
      boxShadow: _shadow(unit),
    ),
    child: Padding(
      padding: EdgeInsets.all(unit * 1.4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: unit * 0.8,
        children: [
          for (final (index, factor) in lines.indexed)
            FractionallySizedBox(
              widthFactor: factor,
              child: _Bar(
                height: unit * (index == 0 ? 1.0 : 0.6),
                color: index == 0 ? palette.ink2 : palette.shadeStrong,
              ),
            ),
        ],
      ),
    ),
  );
}

class _Dot extends StatelessWidget {
  const _Dot({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: size,
    child: DecoratedBox(
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    ),
  );
}

class _Bar extends StatelessWidget {
  const _Bar({required this.height, required this.color, this.width});

  final double? width;
  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: width,
    height: height,
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(height / 4),
      ),
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
