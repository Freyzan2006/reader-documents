import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

import 'sheet_surface.dart';

/// A modal bottom sheet that starts at a partial height and can be dragged
/// up to fill the screen (or down to dismiss). Wraps Forui's [showFSheet]
/// together with Flutter's own [DraggableScrollableSheet].
///
/// Two things Forui's `showFSheet` does *not* do on its own, despite first
/// appearances:
///
/// * **Sizing/dragging.** `FSheetStyle` has no size-related fields at all,
///   and its drag handling (`Sheet`'s `_ShiftedSheet`) gives the content a
///   *fixed* max height (`mainAxisMaxRatio` of the screen) and only slides
///   that fixed box in and out — it does not grow the content as you drag.
///   Forui's own docs point at [DraggableScrollableSheet] for that; this
///   nests one inside the sheet (with `mainAxisMaxRatio: null` and
///   `draggable: false` on the outer sheet, so only the inner one handles
///   drag — Forui's `Sheet` already listens for
///   [DraggableScrollableNotification] and closes the route when dragged
///   down to [minSize], so dismiss-by-drag keeps working).
/// * **Background/chrome.** See [SheetSurface].
///
/// Dimming *is* automatic — Forui applies it via the theme's `colors.barrier`
/// token — but in dark mode that's a subtle tint over an already near-black
/// background, so it reads as much fainter than in light mode. That's by
/// design (Forui's own default), not a bug here.
abstract final class AppSheet {
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget Function(
      BuildContext context,
      ScrollController scrollController,
    )
    builder,
    double initialSize = 0.5,
    double minSize = 0.25,
    double maxSize = 1.0,
  }) => showFSheet<T>(
    context: context,
    side: FLayout.btt,
    mainAxisMaxRatio: null,
    draggable: false,
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: initialSize,
      minChildSize: minSize,
      maxChildSize: maxSize,
      builder: (context, scrollController) => SheetSurface(
        side: FLayout.btt,
        child: builder(context, scrollController),
      ),
    ),
  );
}
