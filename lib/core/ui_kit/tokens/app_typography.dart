import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

abstract final class AppTypography {
  static FTypography of(BuildContext context) => context.theme.typography;
}
