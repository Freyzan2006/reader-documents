import 'package:flutter/widgets.dart';

import 'barrier.dart';
import 'rotation.dart';
import 'sheet.dart';
import 'side_panel.dart';

/// A sheet that adapts to [AppRotation]: normally an [AppSheet] (a draggable
/// bottom sheet), but when shown from inside a rotated surface, an
/// [AppSidePanel] anchored to [AppRotation.bottomEdge] instead, with its
/// content counter-rotated to read upright — a plain anchored popover can't
/// be used there (forui's portal positioning gets the trigger's transform
/// wrong once it includes a rotation), and an unrotated bottom sheet would
/// visually contradict the rotated content it's opened from.
///
/// [builder]'s `scrollController` is only non-null in the unrotated case,
/// where it's the [DraggableScrollableSheet]-managed controller sheets need
/// for drag-to-resize — there's no equivalent concept for a side panel, so
/// content that needs to scroll there should manage that itself (or ignore
/// the `null` and let a plain [GridView]/[ListView] use its own).
abstract final class AppRotatedSheet {
  static void show({
    required BuildContext context,
    required Widget Function(
      BuildContext context,
      ScrollController? scrollController,
      VoidCallback dismiss,
    )
    builder,
    double initialSize = 0.5,
    double minSize = 0.25,
    double maxSize = 1.0,
    EdgeInsetsGeometry panelPadding = EdgeInsets.zero,
    AppBarrierVariant? barrierVariant,
  }) {
    final quarterTurns = AppRotation.of(context);

    if (quarterTurns == 0) {
      AppSheet.show<void>(
        context: context,
        initialSize: initialSize,
        minSize: minSize,
        maxSize: maxSize,
        barrierVariant: barrierVariant,
        builder: (context, scrollController) => builder(
          context,
          scrollController,
          () => Navigator.of(context).pop(),
        ),
      );
      return;
    }

    AppSidePanel.show(
      context: context,
      side: AppRotation.bottomEdge(context),
      panelFraction: initialSize,
      barrierVariant: barrierVariant,
      builder: (context, panel) => Padding(
        padding: panelPadding,
        child: RotatedBox(
          quarterTurns: quarterTurns,
          child: ScrollConfiguration(
            behavior: ScrollConfiguration.of(context)
                .copyWith(overscroll: false),
            child: builder(context, null, panel.close),
          ),
        ),
      ),
    );
  }
}
