import 'package:flutter/widgets.dart';

import '../theme/app_tokens.dart';
import '../tokens/app_palette.dart';
import '../tokens/app_radius.dart';

enum AppThumbnailPreviewKind { page, placeholder }

class AppThumbnailPreview extends StatelessWidget {
  const AppThumbnailPreview({required this.kinds, super.key});

  final List<AppThumbnailPreviewKind> kinds;

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
        child: switch (kinds) {
          [final single] => _Pane(kind: single, palette: palette),
          [final first, final second, ...] => Stack(
            fit: StackFit.expand,
            children: [
              _Pane(kind: first, palette: palette),
              ClipPath(
                clipper: const _LowerTriangle(),
                child: _Pane(kind: second, palette: palette),
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
  const _Pane({required this.kind, required this.palette});

  final AppThumbnailPreviewKind kind;
  final AppPalette palette;

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: palette.paper,
    child: LayoutBuilder(
      builder: (context, constraints) {
        final unit = constraints.maxWidth / 24;
        return Padding(
          padding: EdgeInsets.fromLTRB(unit * 2.2, unit * 2.4, unit * 2.2, 0),
          child: Column(
            spacing: unit * 1.4,
            children: [
              for (var row = 0; row < 2; row++)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: unit * 1.4,
                  children: [
                    for (var col = 0; col < 2; col++)
                      Expanded(
                        child: _Sheet(
                          kind: kind,
                          palette: palette,
                          unit: unit,
                          variant: row * 2 + col,
                        ),
                      ),
                  ],
                ),
            ],
          ),
        );
      },
    ),
  );
}

class _Sheet extends StatelessWidget {
  const _Sheet({
    required this.kind,
    required this.palette,
    required this.unit,
    required this.variant,
  });

  final AppThumbnailPreviewKind kind;
  final AppPalette palette;
  final double unit;

  final int variant;

  @override
  Widget build(BuildContext context) => AspectRatio(
    aspectRatio: 1 / 1.414,
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: palette.sheet,
        borderRadius: BorderRadius.circular(unit * 0.5),
        border: Border.all(color: palette.rule),
      ),
      child: Padding(
        padding: EdgeInsets.all(unit * 1.1),
        child: switch (kind) {
          AppThumbnailPreviewKind.page => _page(),
          AppThumbnailPreviewKind.placeholder => _placeholder(),
        },
      ),
    ),
  );

  Widget _page() {
    final picture = variant.isEven;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: unit * 0.6,
      children: [
        FractionallySizedBox(
          widthFactor: variant == 1 ? 0.55 : 0.75,
          child: _Bar(height: unit * 0.8, color: palette.ink),
        ),
        if (picture)
          SizedBox(
            height: unit * 4,
            width: double.infinity,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: palette.ink3,
                borderRadius: BorderRadius.circular(unit * 0.3),
              ),
            ),
          ),
        for (final factor
            in picture
                ? const [1.0, 0.9, 0.6]
                : const [1.0, 0.95, 1.0, 0.8, 1.0, 0.5])
          FractionallySizedBox(
            widthFactor: factor,
            child: _Bar(height: unit * 0.4, color: palette.ink2),
          ),
      ],
    );
  }

  Widget _placeholder() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    spacing: unit * 0.6,
    children: [
      Container(
        width: unit * 3.2,
        height: unit * 1.5,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(unit * 0.4),
          border: Border.all(color: palette.ruleStrong, width: unit * 0.15),
        ),
      ),
      SizedBox(height: unit * 0.4),
      for (final factor in const [0.6, 1.0, 1.0, 0.8, 0.45])
        FractionallySizedBox(
          widthFactor: factor,
          child: _Bar(height: unit * 0.4, color: palette.shade),
        ),
    ],
  );
}

class _Bar extends StatelessWidget {
  const _Bar({required this.height, required this.color});

  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) => SizedBox(
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
