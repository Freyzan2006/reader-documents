import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

/// Border-width tokens.
///
/// Forui exposes a single default width (`context.theme.style.borderWidth`,
/// used by its own widgets). This adds a small scale on top for our own
/// primitives (dividers, grid outlines, etc.) that want something thinner or
/// thicker than the component default.
abstract final class AppBorderWidth {
  static const double hairline = 0.5;
  static const double thin = 1;
  static const double thick = 2;
}

/// Ready-made borders using Forui's border color, for visual consistency with
/// Forui's own widgets.
abstract final class AppBorders {
  static Color color(BuildContext context) => context.theme.colors.border;

  static Border all(
    BuildContext context, {
    double width = AppBorderWidth.thin,
  }) => Border.all(color: color(context), width: width);
}
