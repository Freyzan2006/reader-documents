import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

import '../tokens/app_borders.dart';
import '../tokens/app_radius.dart';

/// Shared visual chrome for [AppSheet] and [AppSidePanel].
///
/// Forui's [FSheetStyle] (the base style for both the modal and persistent
/// sheet styles) has no decoration token at all — no background, no rounded
/// corners. Both sheet types need the same surface, so it's built once here
/// instead of duplicated per type.
///
/// Vertical sides (a bottom/top sheet) get rounded corners on the free edge
/// and a drag handle. Horizontal sides (a side panel) get a border on the
/// edge touching the rest of the app instead — a handle bar reads as
/// "draggable" in a way a docked side panel usually isn't.
class SheetSurface extends StatelessWidget {
  const SheetSurface({required this.side, required this.child, super.key});

  final FLayout side;
  final Widget child;

  static BorderRadius _cornerRadius(FLayout side, BorderRadius r) =>
      switch (side) {
        FLayout.btt => BorderRadius.only(
          topLeft: r.topLeft,
          topRight: r.topRight,
        ),
        FLayout.ttb => BorderRadius.only(
          bottomLeft: r.bottomLeft,
          bottomRight: r.bottomRight,
        ),
        FLayout.ltr => BorderRadius.only(
          topRight: r.topRight,
          bottomRight: r.bottomRight,
        ),
        FLayout.rtl => BorderRadius.only(
          topLeft: r.topLeft,
          bottomLeft: r.bottomLeft,
        ),
      };

  static Border _edgeBorder(FLayout side, Color color) => switch (side) {
    FLayout.ltr => Border(right: BorderSide(color: color)),
    FLayout.rtl => Border(left: BorderSide(color: color)),
    FLayout.ttb || FLayout.btt => const Border(),
  };

  @override
  Widget build(BuildContext context) => SizedBox.expand(
    // Forui's `FSheets` (backing both `showFSheet` and `showFPersistentSheet`)
    // stacks sheets via a plain `Stack`, which gives each sheet *loose* — not
    // tight — constraints. Without this, a side panel sizes to its content
    // instead of filling the available height.
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: context.theme.colors.card,
        borderRadius: side.vertical
            ? _cornerRadius(side, AppRadius.of(context).lg)
            : null,
        border: side.vertical
            ? null
            : _edgeBorder(side, AppBorders.color(context)),
      ),
      child: SafeArea(
        child: side.vertical
            ? Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: _Handle(),
                  ),
                  Expanded(child: child),
                ],
              )
            : child,
      ),
    ),
  );
}

class _Handle extends StatelessWidget {
  const _Handle();

  @override
  Widget build(BuildContext context) => Center(
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: context.theme.colors.border,
        borderRadius: BorderRadius.circular(999),
      ),
      child: const SizedBox(width: 36, height: 4),
    ),
  );
}
