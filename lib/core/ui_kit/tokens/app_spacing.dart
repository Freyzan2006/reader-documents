/// The app's spacing scale, in logical pixels.
///
/// Forui ships token scales for color, typography and border radius, but not
/// spacing — this is the one token set here that's entirely our own. Values
/// are multiples of 4, matching the base unit Forui's own widgets use
/// internally for padding.
///
/// Usage: `Row(spacing: AppSpacing.md, children: [...])` (Flutter's `Row`/
/// `Column` support `spacing` natively), or [AppGap] where a `spacing:`
/// parameter isn't available, e.g. inside a `ListView`'s `children`.
abstract final class AppSpacing {
  static const double none = 0;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xl2 = 32;
  static const double xl3 = 48;
  static const double xl4 = 64;
}
