import 'package:flutter/widgets.dart';

import '../theme/app_tokens.dart';
import '../tokens/app_palette.dart';
import '../tokens/app_radius.dart';

enum AppLayoutPreviewKind { rows, grid }

class AppLayoutPreview extends StatelessWidget {
  const AppLayoutPreview({required this.kinds, super.key});

  final List<AppLayoutPreviewKind> kinds;

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
          [final narrow, final wide, ...] => _Devices(
            narrow: narrow,
            wide: wide,
            palette: palette,
          ),
          _ => const SizedBox.shrink(),
        },
      ),
    );
  }
}

class _Devices extends StatelessWidget {
  const _Devices({
    required this.narrow,
    required this.wide,
    required this.palette,
  });

  final AppLayoutPreviewKind narrow;
  final AppLayoutPreviewKind wide;
  final AppPalette palette;

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: palette.shade,
    child: LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;
        final unit = w / 24;
        return Stack(
          children: [
            Positioned(
              right: unit * 1.6,
              top: unit * 2.2,
              width: w * 0.74,
              height: h * 0.5,
              child: _Device(
                kind: wide,
                palette: palette,
                unit: unit,
                columns: 3,
              ),
            ),
            Positioned(
              left: unit * 1.6,
              bottom: unit * 1.8,
              width: w * 0.42,
              height: h * 0.6,
              child: _Device(kind: narrow, palette: palette, unit: unit),
            ),
          ],
        );
      },
    ),
  );
}

class _Device extends StatelessWidget {
  const _Device({
    required this.kind,
    required this.palette,
    required this.unit,
    this.columns = 2,
  });

  final AppLayoutPreviewKind kind;
  final AppPalette palette;
  final double unit;
  final int columns;

  @override
  Widget build(BuildContext context) {
    final inner = unit * 0.7;
    final radius = BorderRadius.circular(unit * 1.4);
    return DecoratedBox(
      position: DecorationPosition.foreground,
      decoration: BoxDecoration(
        borderRadius: radius,
        border: Border.all(color: palette.ink2, width: unit * 0.6),
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: _Pane(
          kind: kind,
          palette: palette,
          unit: inner,
          columns: columns,
          rows: kind == AppLayoutPreviewKind.grid ? 1 : 5,
        ),
      ),
    );
  }
}

class _Pane extends StatelessWidget {
  const _Pane({
    required this.kind,
    required this.palette,
    this.unit,
    this.columns = 2,
    this.rows,
  });

  final AppLayoutPreviewKind kind;
  final AppPalette palette;

  final double? unit;
  final int columns;

  final int? rows;

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: palette.paper,
    child: LayoutBuilder(
      builder: (context, constraints) {
        final unit = this.unit ?? constraints.maxWidth / 24;
        return ClipRect(
          child: OverflowBox(
            alignment: Alignment.topLeft,
            maxHeight: double.infinity,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                unit * 2.2,
                unit * 2.4,
                unit * 2.2,
                0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                spacing: unit * 1.2,
                children: [
                  _Bar(height: unit * 2.4, color: palette.shade, round: true),
                  ...switch (kind) {
                    AppLayoutPreviewKind.rows => _rows(unit),
                    AppLayoutPreviewKind.grid => _grid(unit),
                  },
                ],
              ),
            ),
          ),
        );
      },
    ),
  );

  List<Widget> _rows(double unit) => [
    for (var i = 0; i < (rows ?? 5); i++) ...[
      if (i > 0)
        Padding(
          padding: EdgeInsets.only(left: unit * 5.4),
          child: SizedBox(height: 1, child: ColoredBox(color: palette.rule)),
        ),
      Row(
        spacing: unit * 1.4,
        children: [
          SizedBox(
            width: unit * 4,
            child: _Sheet(palette: palette, unit: unit, read: i == 0),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: unit * 0.8,
              children: [
                FractionallySizedBox(
                  widthFactor: i.isEven ? 0.85 : 0.65,
                  child: _Bar(height: unit * 1.1, color: palette.ink),
                ),
                FractionallySizedBox(
                  widthFactor: 0.45,
                  child: _Bar(height: unit * 0.7, color: palette.ink3),
                ),
              ],
            ),
          ),
        ],
      ),
    ],
  ];

  List<Widget> _grid(double unit) => [
    for (var row = 0; row < (rows ?? 2); row++)
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: unit * 1.2,
        children: [
          for (var col = 0; col < columns; col++)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: unit * 0.7,
                children: [
                  _Sheet(
                    palette: palette,
                    unit: unit,
                    read: row == 0 && col == 0,
                  ),
                  FractionallySizedBox(
                    widthFactor: col.isEven ? 0.85 : 0.65,
                    child: _Bar(height: unit * 0.9, color: palette.ink),
                  ),
                  FractionallySizedBox(
                    widthFactor: 0.45,
                    child: _Bar(height: unit * 0.6, color: palette.ink3),
                  ),
                ],
              ),
            ),
        ],
      ),
  ];
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
        borderRadius: BorderRadius.circular(unit * 0.4),
        border: Border.all(color: palette.rule),
      ),
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.all(unit * 0.8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: unit * 0.5,
              children: [
                for (final factor in const [0.6, 1.0, 1.0, 0.5])
                  FractionallySizedBox(
                    widthFactor: factor,
                    child: _Bar(height: unit * 0.4, color: palette.shadeStrong),
                  ),
              ],
            ),
          ),
          if (read)
            Positioned(
              left: 0,
              bottom: 0,
              width: unit * 2,
              height: unit * 0.4,
              child: ColoredBox(color: palette.ink),
            ),
        ],
      ),
    ),
  );
}

class _Bar extends StatelessWidget {
  const _Bar({required this.height, required this.color, this.round = false});

  final double height;
  final Color color;
  final bool round;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: height,
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(round ? height / 2 : height / 4),
      ),
    ),
  );
}
