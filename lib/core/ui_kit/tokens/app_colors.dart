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

  static FColors of(BuildContext context) => context.theme.colors;
}
