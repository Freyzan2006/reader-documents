import 'package:flutter/widgets.dart';

import '../theme/app_tokens.dart';
import '../tokens/app_palette.dart';
import '../tokens/app_typography.dart';

enum AppTextVariant {
  display,
  title,
  subtitle,
  item,
  body,
  label,
  caption,
  numeral,
  meta,
  overline,
  annotation,
  code;

  TextStyle get style => switch (this) {
    display => AppTextStyles.display,
    title => AppTextStyles.title,
    subtitle => AppTextStyles.subtitle,
    item => AppTextStyles.item,
    body || annotation => AppTextStyles.body,
    label => AppTextStyles.label,
    caption => AppTextStyles.caption,
    numeral => AppTextStyles.numeral,
    meta || code => AppTextStyles.meta,
    overline => AppTextStyles.overline,
  };

  Color colorIn(AppPalette palette) => switch (this) {
    display || title || subtitle || item || label || numeral => palette.ink,
    annotation || code => palette.ink,
    body || caption => palette.ink2,
    meta || overline => palette.ink3,
  };
}

class AppText extends StatelessWidget {
  const AppText(
    this.data, {
    this.variant = AppTextVariant.body,
    this.color,
    this.maxLines,
    this.overflow,
    this.textAlign,
    super.key,
  });

  final String data;
  final AppTextVariant variant;
  final Color? color;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextAlign? textAlign;

  static TextStyle styleOf(
    BuildContext context,
    AppTextVariant variant, {
    Color? color,
  }) {
    final palette = context.tokens.palette;
    final style = variant.style.copyWith(
      color: color ?? variant.colorIn(palette),
    );
    return variant == AppTextVariant.annotation
        ? style.copyWith(
            decoration: TextDecoration.underline,
            decorationColor: palette.ink,
            decorationThickness: 2,
          )
        : style;
  }

  @override
  Widget build(BuildContext context) => Text(
    variant == AppTextVariant.overline ? data.toUpperCase() : data,
    style: styleOf(context, variant, color: color),
    maxLines: maxLines,
    overflow: overflow,
    textAlign: textAlign,
  );
}
