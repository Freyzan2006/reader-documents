import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

/// Brand colors.
///
/// Kept separate from `AppTheme` (`lib/core/ui_kit/theme/app_theme.dart`) so
/// the palette itself lives in the tokens layer alongside spacing/radius/
/// borders, while `AppTheme` stays responsible only for assembling Forui's
/// `FThemeData` from these values.
///
/// The brand is monochrome: graphite (near-black) as the primary accent on
/// light backgrounds, silver (near-white, but with more character than plain
/// gray) as the primary accent on dark backgrounds.
abstract final class AppColors {
  static const graphite = Color(0xFF1C1C1E);
  static const silver = Color(0xFFC7C7CC);

  static const primaryLight = graphite;
  static const primaryDark = silver;

  static const successLight = Color(0xFF15803D);
  static const successDark = Color(0xFF4ADE80);
  static const successForegroundLight = Color(0xFFFFFFFF);
  static const successForegroundDark = Color(0xFF0A0A0A);

  // Pantone 18-1438 "Marsala".
  static const accentLight = Color(0xFF955251);
  static const accentDark = Color(0xFFC98C8B);
  static const accentForegroundLight = Color(0xFFFFFFFF);
  static const accentForegroundDark = Color(0xFF0A0A0A);

  static const warningLight = Color(0xFFB45309);
  static const warningDark = Color(0xFFFBBF24);
  static const warningForegroundLight = Color(0xFFFFFFFF);
  static const warningForegroundDark = Color(0xFF0A0A0A);

  static FColors of(BuildContext context) => context.theme.colors;

  static Color success(BuildContext context) =>
      of(context).brightness == Brightness.dark ? successDark : successLight;

  static Color successForeground(BuildContext context) =>
      of(context).brightness == Brightness.dark
      ? successForegroundDark
      : successForegroundLight;

  static Color accent(BuildContext context) =>
      of(context).brightness == Brightness.dark ? accentDark : accentLight;

  static Color accentForeground(BuildContext context) =>
      of(context).brightness == Brightness.dark
      ? accentForegroundDark
      : accentForegroundLight;

  static Color warning(BuildContext context) =>
      of(context).brightness == Brightness.dark ? warningDark : warningLight;

  static Color warningForeground(BuildContext context) =>
      of(context).brightness == Brightness.dark
      ? warningForegroundDark
      : warningForegroundLight;
}
