import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

/// Corner-radius tokens.
///
/// Forui already ships a full radius scale ([FBorderRadius], reachable via
/// `context.theme.style.borderRadius`). [AppRadius.of] just gives our own
/// widgets a stable name to depend on instead of reaching into Forui's theme
/// directly — if the underlying UI kit is ever swapped, only this file
/// changes.
abstract final class AppRadius {
  static FBorderRadius of(BuildContext context) =>
      context.theme.style.borderRadius;
}
