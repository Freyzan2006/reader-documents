import 'package:flutter/widgets.dart';

abstract final class AppFonts {
  static const sans = 'IBM Plex Sans';
  static const mono = 'JetBrains Mono';
}

abstract final class AppTextStyles {
  static const _tabular = [FontFeature.tabularFigures()];

  static const display = TextStyle(
    fontFamily: AppFonts.sans,
    fontSize: 28,
    height: 34 / 28,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.56,
  );

  static const title = TextStyle(
    fontFamily: AppFonts.sans,
    fontSize: 20,
    height: 26 / 20,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
  );

  static const subtitle = TextStyle(
    fontFamily: AppFonts.sans,
    fontSize: 16,
    height: 22 / 16,
    fontWeight: FontWeight.w600,
  );

  static const item = TextStyle(
    fontFamily: AppFonts.sans,
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w600,
  );

  static const body = TextStyle(
    fontFamily: AppFonts.sans,
    fontSize: 15,
    height: 22 / 15,
    fontWeight: FontWeight.w400,
  );

  static const label = TextStyle(
    fontFamily: AppFonts.sans,
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w500,
  );

  static const caption = TextStyle(
    fontFamily: AppFonts.sans,
    fontSize: 13,
    height: 18 / 13,
    fontWeight: FontWeight.w400,
  );

  static const numeral = TextStyle(
    fontFamily: AppFonts.mono,
    fontSize: 22,
    height: 28 / 22,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.22,
    fontFeatures: _tabular,
  );

  static const meta = TextStyle(
    fontFamily: AppFonts.mono,
    fontSize: 12,
    height: 16 / 12,
    fontWeight: FontWeight.w500,
    fontFeatures: _tabular,
  );

  static const overline = TextStyle(
    fontFamily: AppFonts.mono,
    fontSize: 11,
    height: 14 / 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.88,
    fontFeatures: _tabular,
  );
}
