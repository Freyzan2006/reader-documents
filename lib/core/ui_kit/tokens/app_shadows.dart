import 'package:flutter/widgets.dart';

/// Shared "overlay elevation" — the drop shadow that separates a modal
/// surface (a dialog, a side panel, a sheet) from the dimmed barrier behind
/// it. Kept as one token so every overlay reads the same depth cue instead of
/// each tuning its own color/blur by feel — and so it stays cheap: a
/// [BoxShadow] is rasterized only near the surface's own bounds, unlike a
/// full-screen backdrop blur.
abstract final class AppShadows {
  static const Color _color = Color(0x80000000);
  static const double _blurRadius = 24;
  static const double _edgeOffset = 3;

  /// Cast toward [direction] — the surface's free edge, the one facing
  /// whatever's behind it, not the rest of the app. Use with a unit [Offset]
  /// (e.g. `Offset(0, -1)` for a shadow above the surface).
  static List<BoxShadow> towards(Offset direction) => [
    BoxShadow(
      color: _color,
      blurRadius: _blurRadius,
      offset: direction * _edgeOffset,
    ),
  ];

  /// Omnidirectional — for a surface with no single free edge, such as a
  /// centered dialog floating above the barrier on every side.
  static const List<BoxShadow> floating = [
    BoxShadow(color: _color, blurRadius: _blurRadius),
  ];
}
