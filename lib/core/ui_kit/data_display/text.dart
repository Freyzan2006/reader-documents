import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

/// A small, opinionated set of text styles built on Forui's typography scale
/// (`context.theme.typography.display`/`.body`, each with its own `xs`...`xl8`
/// sizes) — this doesn't re-expose that whole scale, just the roles screens
/// actually need.
enum AppTextVariant { display, title, body, caption }

/// Themed text. Wraps a plain [Text] styled from [AppTextVariant].
class AppText extends StatelessWidget {
  const AppText(
    this.data, {
    this.variant = AppTextVariant.body,
    this.color,
    super.key,
  });

  final String data;
  final AppTextVariant variant;
  final Color? color;

  static TextStyle _style(BuildContext context, AppTextVariant variant) {
    final typography = context.theme.typography;
    return switch (variant) {
      AppTextVariant.display => typography.display.xl2,
      AppTextVariant.title => typography.display.lg,
      AppTextVariant.body => typography.body.md,
      AppTextVariant.caption => typography.body.sm,
    };
  }

  @override
  Widget build(BuildContext context) {
    final style = _style(context, variant);
    return Text(
      data,
      style: color == null ? style : style.copyWith(color: color),
    );
  }
}
