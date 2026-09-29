import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

abstract final class AppTypography {
  /// The app's single font family, bundled as a local asset (see
  /// `pubspec.yaml`'s `fonts:` section) rather than fetched at runtime — this
  /// app ships with a "nothing leaves the device" privacy stance, so a
  /// package like `google_fonts` that downloads on first use is off the
  /// table.
  static const String fontFamily = 'JetBrains Mono';

  /// Builds the app's [FTypography] — [fontFamily] for both the `display`
  /// and `body` typefaces, sized for [touch].
  static FTypography build({required FColors colors, required bool touch}) {
    final typeface = FTypeface.inherit(
      colors: colors,
      touch: touch,
      fontFamily: fontFamily,
    );
    return FTypography(display: typeface, body: typeface);
  }

  static FTypography of(BuildContext context) => context.theme.typography;
}
