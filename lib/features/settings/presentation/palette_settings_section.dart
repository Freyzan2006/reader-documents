import 'package:flutter/widgets.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';
import 'package:reader_documents/l10n/app_localizations.dart';

class PaletteSettingsSection extends StatelessWidget {
  const PaletteSettingsSection({
    required this.palette,
    required this.onChanged,
    super.key,
  });

  static const _cardWidth = 132.0;

  final AppPaletteFamily palette;
  final ValueChanged<AppPaletteFamily> onChanged;

  static String label(AppLocalizations l10n, AppPaletteFamily family) =>
      switch (family) {
        AppPaletteFamily.monochrome => l10n.paletteMonochrome,
        AppPaletteFamily.ink => l10n.paletteInk,
      };

  static String _themes(AppLocalizations l10n, AppPaletteFamily family) =>
      switch (family) {
        AppPaletteFamily.monochrome => l10n.paletteMonochromeThemes,
        AppPaletteFamily.ink => l10n.paletteInkThemes,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: AppSpacing.sm,
          children: [
            for (final family in AppPaletteFamily.values)
              SizedBox(
                width: _cardWidth,
                child: _PaletteCard(
                  family: family,
                  label: label(l10n, family),
                  themes: _themes(l10n, family),
                  selected: family == palette,
                  onPressed: () => onChanged(family),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PaletteCard extends StatelessWidget {
  const _PaletteCard({
    required this.family,
    required this.label,
    required this.themes,
    required this.selected,
    required this.onPressed,
  });

  final AppPaletteFamily family;
  final String label;
  final String themes;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final palette = tokens.palette;
    final light = AppPalette.of(Brightness.light, family);
    final dark = AppPalette.of(Brightness.dark, family);

    return Semantics(
      inMutuallyExclusiveGroup: true,
      checked: selected,
      child: AppTappable(
        onPressed: onPressed,
        selected: selected,
        semanticsLabel: '$label, $themes',
        excludeChildSemantics: true,
        pressedOpacity: 0.85,
        child: AnimatedContainer(
          duration: tokens.motion.quick,
          padding: const EdgeInsets.all(AppSpacing.md),
          foregroundDecoration: BoxDecoration(
            borderRadius: AppRadii.md,
            border: Border.all(
              color: selected ? palette.ink : palette.rule,
              width: selected ? 2 : 1,
            ),
          ),
          decoration: BoxDecoration(
            color: palette.sheet,
            borderRadius: AppRadii.md,
          ),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: AppSpacing.sm,
                children: [
                  _Swatches(
                    // Three swatches leave room for the check badge.
                    colors: [light.paper, light.ink, dark.paper],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(label, variant: AppTextVariant.item),
                      AppText(themes, variant: AppTextVariant.meta),
                    ],
                  ),
                ],
              ),
              if (selected)
                const Positioned(
                  top: 0,
                  right: 0,
                  child: AppCheckMark(checked: true, round: true, size: 20),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Swatches extends StatelessWidget {
  const _Swatches({required this.colors});

  static const _size = 28.0;
  static const _overlap = 6.0;

  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    final rule = context.tokens.palette.rule;
    final step = _size - _overlap;
    return SizedBox(
      width: colors.isEmpty ? 0 : _size + step * (colors.length - 1),
      height: _size,
      child: Stack(
        children: [
          for (final (index, color) in colors.indexed)
            Positioned(
              left: step * index,
              top: 0,
              width: _size,
              height: _size,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: AppRadii.xs,
                  border: Border.all(color: rule),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
