import 'package:flutter/widgets.dart';

import '../theme/graphics_mode.dart';

@immutable
final class AppElevation {
  const AppElevation._({
    required this.pop,
    required this.sheet,
    required this.fab,
  });

  static const _qualityLight = AppElevation._(
    pop: [
      BoxShadow(color: Color(0x0F000000), offset: Offset(0, 1), blurRadius: 2),
      BoxShadow(color: Color(0x1A000000), offset: Offset(0, 8), blurRadius: 24),
    ],
    sheet: [
      BoxShadow(
        color: Color(0x26000000),
        offset: Offset(0, -8),
        blurRadius: 32,
      ),
    ],
    fab: [
      BoxShadow(color: Color(0x33000000), offset: Offset(0, 4), blurRadius: 12),
    ],
  );

  static const _qualityDark = AppElevation._(
    pop: [
      BoxShadow(color: Color(0x14FFFFFF), spreadRadius: 1),
      BoxShadow(color: Color(0x80000000), offset: Offset(0, 8), blurRadius: 24),
    ],
    sheet: [
      BoxShadow(
        color: Color(0xA3000000),
        offset: Offset(0, -8),
        blurRadius: 32,
      ),
    ],
    fab: [
      BoxShadow(color: Color(0x99000000), offset: Offset(0, 4), blurRadius: 12),
    ],
  );

  static const _performanceLight = AppElevation._(
    pop: [BoxShadow(color: Color(0x24000000), spreadRadius: 1)],
    sheet: [BoxShadow(color: Color(0x24000000), offset: Offset(0, -1))],
    fab: [BoxShadow(color: Color(0x24000000), spreadRadius: 1)],
  );

  static const _performanceDark = AppElevation._(
    pop: [BoxShadow(color: Color(0x29FFFFFF), spreadRadius: 1)],
    sheet: [BoxShadow(color: Color(0x29FFFFFF), offset: Offset(0, -1))],
    fab: [BoxShadow(color: Color(0x29FFFFFF), spreadRadius: 1)],
  );

  static AppElevation resolve(Brightness brightness, GraphicsMode mode) =>
      switch ((brightness, mode)) {
        (Brightness.light, GraphicsMode.quality) => _qualityLight,
        (Brightness.dark, GraphicsMode.quality) => _qualityDark,
        (Brightness.light, GraphicsMode.performance) => _performanceLight,
        (Brightness.dark, GraphicsMode.performance) => _performanceDark,
      };

  final List<BoxShadow> pop;
  final List<BoxShadow> sheet;
  final List<BoxShadow> fab;
}

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
