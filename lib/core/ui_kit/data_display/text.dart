import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

import '../tokens/app_colors.dart';
import '../tokens/app_typography.dart';

/// A small, opinionated set of text styles built on Forui's typography scale
/// (`context.theme.typography.display`/`.body`, each with its own `xs`...`xl8`
/// sizes) — this doesn't re-expose that whole scale, just the roles screens
/// actually need.
enum AppTextVariant { display, title, body, caption, annotation }

/// Themed text. Wraps a plain [Text] styled from [AppTextVariant].
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

  static TextStyle _style(BuildContext context, AppTextVariant variant) {
    final typography = AppTypography.of(context);
    return switch (variant) {
      AppTextVariant.display => typography.display.xl2,
      AppTextVariant.title => typography.display.lg,
      AppTextVariant.body => typography.body.md,
      AppTextVariant.caption => typography.body.sm,
      AppTextVariant.annotation => typography.body.md,
    };
  }

  static Color _defaultColor(BuildContext context, AppTextVariant variant) {
    final colors = context.theme.colors;
    return switch (variant) {
      AppTextVariant.display => colors.foreground,
      AppTextVariant.title => colors.foreground,
      AppTextVariant.body => colors.mutedForeground,
      AppTextVariant.caption => colors.mutedForeground,
      AppTextVariant.annotation => colors.foreground,
    };
  }

  static TextStyle styleOf(
    BuildContext context,
    AppTextVariant variant, {
    Color? color,
  }) {
    final style = _style(
      context,
      variant,
    ).copyWith(color: color ?? _defaultColor(context, variant));

    return variant == AppTextVariant.annotation
        ? style.copyWith(
            decoration: TextDecoration.underline,
            decorationColor: AppColors.accent(context),
            decorationThickness: 2,
          )
        : style;
  }

  @override
  Widget build(BuildContext context) => Text(
    data,
    style: styleOf(context, variant, color: color),
    maxLines: maxLines,
    overflow: overflow,
    textAlign: textAlign,
  );
}
