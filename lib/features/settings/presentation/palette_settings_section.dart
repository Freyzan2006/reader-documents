import 'package:flutter/widgets.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';
import 'package:reader_documents/l10n/app_localizations.dart';

class PaletteSettingsSection extends StatelessWidget {
  const PaletteSettingsSection({super.key});

  static const _cardWidth = 132.0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final palette = context.tokens.palette;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: AppSpacing.sm,
          children: [
            Semantics(
              selected: true,
              label: l10n.paletteMonochrome,
              excludeSemantics: true,
              child: Container(
                width: _cardWidth,
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: palette.sheet,
                  borderRadius: AppRadii.md,
                  border: Border.all(color: palette.ink, width: 2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: AppSpacing.sm,
                  children: [
                    _Swatches(
                      colors: [palette.paper, palette.ruleStrong, palette.ink],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(
                          l10n.paletteMonochrome,
                          variant: AppTextVariant.item,
                        ),
                        AppText(
                          l10n.paletteMonochromeThemes,
                          variant: AppTextVariant.meta,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: _cardWidth,
              child: CustomPaint(
                painter: _DashedBorder(color: palette.ruleStrong),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Center(
                    child: AppText(
                      l10n.palettesComingSoon,
                      variant: AppTextVariant.caption,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Swatches extends StatelessWidget {
  const _Swatches({required this.colors});

  static const _height = 28.0;
  static const _overlap = 6.0;

  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    final rule = context.tokens.palette.rule;
    return SizedBox(
      height: _height,
      child: Row(
        children: [
          for (final (index, color) in colors.indexed)
            Expanded(
              child: Transform.translate(
                offset: Offset(-_overlap * index, 0),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: AppRadii.xs,
                    border: Border.all(color: rule),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _DashedBorder extends CustomPainter {
  const _DashedBorder({required this.color});

  static const _dash = 4.0;
  static const _gap = 3.0;

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final path = Path()
      ..addRRect(AppRadii.md.toRRect(Offset.zero & size).deflate(0.5));
    for (final metric in path.computeMetrics()) {
      for (var d = 0.0; d < metric.length; d += _dash + _gap) {
        canvas.drawPath(metric.extractPath(d, d + _dash), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorder oldDelegate) => oldDelegate.color != color;
}
