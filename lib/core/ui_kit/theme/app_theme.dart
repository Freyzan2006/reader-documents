import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

import '../tokens/app_colors.dart';

/// The app's own theming layer on top of Forui.
///
/// Forui ships a "neutral" base palette (`FColors.neutralLight`/`neutralDark`).
/// Instead of consuming it as-is, we derive our brand palette (see
/// [AppColors]) from it here, in one place. Re-skinning the app (or swapping
/// Forui for something else later) means touching this file, not every
/// screen that uses [FButton]/[FCard]/etc.
abstract final class AppTheme {
  static final FThemeData light = FThemeData(
    touch: true,
    debugLabel: 'Reader Documents Light',
    colors: FColors.neutralLight.copyWith(
      primary: AppColors.primaryLight,
      primaryForeground: const Color(0xFFFFFFFF),
    ),
  );

  static final FThemeData dark = FThemeData(
    touch: true,
    debugLabel: 'Reader Documents Dark',
    colors: FColors.neutralDark.copyWith(
      primary: AppColors.primaryDark,
      primaryForeground: const Color(0xFF0A0A0A),
    ),
  );

  static FThemeData of(Brightness brightness) =>
      brightness == Brightness.dark ? dark : light;
}
