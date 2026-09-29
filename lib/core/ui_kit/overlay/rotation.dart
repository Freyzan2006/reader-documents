import 'package:flutter/widgets.dart';

import 'side_panel.dart';

/// The ambient rotation of the current content surface, in quarter turns
/// clockwise — set once where a `RotatedBox` wraps a whole screen (e.g. the
/// document viewer's reading surface), and read anywhere below it that needs
/// to launch an overlay (a sheet, side panel, or menu).
///
/// Without this, every widget that might need to open such an overlay has to
/// receive `quarterTurns` as an explicit constructor parameter just to
/// forward it — which is how the document viewer's toolbar, minimap, and
/// notes sheet all ended up threading it, even though most of them never use
/// it for anything else. Reading it ambiently instead means a widget that
/// doesn't open an overlay never needs to know about rotation at all, and one
/// that does can just ask.
///
/// Defaults to 0 when no ancestor [AppRotation] exists, so anything reading
/// this works unchanged outside a rotated context.
class AppRotation extends InheritedWidget {
  const AppRotation({
    required this.quarterTurns,
    required super.child,
    super.key,
  });

  final int quarterTurns;

  static int of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppRotation>()?.quarterTurns ??
      0;

  /// The true screen edge that corresponds to the rotated surface's own
  /// "bottom" — `RotatedBox` rotates clockwise, so each +1 quarter turn walks
  /// bottom→left→top→right. Anchoring a side panel here reads as sliding in
  /// from the bottom of the rotated content, not an arbitrary screen edge.
  static AppEdge bottomEdge(BuildContext context) => const [
    AppEdge.bottom,
    AppEdge.left,
    AppEdge.top,
    AppEdge.right,
  ][of(context) % 4];

  @override
  bool updateShouldNotify(AppRotation oldWidget) =>
      quarterTurns != oldWidget.quarterTurns;
}
