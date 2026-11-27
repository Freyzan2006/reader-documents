import 'package:flutter/widgets.dart';

import '../theme/app_tokens.dart';

abstract final class AppBorderWidth {
  static const double hairline = 0.5;
  static const double thin = 1;
  static const double thick = 2;
}

abstract final class AppBorders {
  static Color color(BuildContext context) => context.tokens.palette.rule;

  static Border all(
    BuildContext context, {
    double width = AppBorderWidth.thin,
  }) => Border.all(color: color(context), width: width);
}
