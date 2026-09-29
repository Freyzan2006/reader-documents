import 'package:flutter/services.dart';
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
/// token. In dark mode that tint sits over an already near-black background,
/// so it reads fainter than in light mode; a backdrop blur would fix that but
/// costs a full-screen re-sample every frame, so [SheetSurface] instead gets
/// a drop shadow — cheap (rasterized only near its own edge) and enough to
/// read as "above" the barrier regardless of how dark the barrier is.
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
  }) {
    HapticFeedback.lightImpact();
    return showFSheet<T>(
      context: context,
      side: FLayout.btt,
      mainAxisMaxRatio: null,
      draggable: false,
      builder: (context) => _HapticDismissDrag(
        initialSize: initialSize,
        minSize: minSize,
        maxSize: maxSize,
        builder: builder,
      ),
    );
  }
}

/// Fires a haptic the moment a drag first reaches the dismiss threshold —
/// edge-triggered on [_armed] so it fires once per approach, not on every
/// notification while held there. Forui's own `Sheet` listens for the same
/// [DraggableScrollableNotification] to actually close the route; returning
/// `false` here lets that notification keep bubbling up to it.
class _HapticDismissDrag extends StatefulWidget {
  const _HapticDismissDrag({
    required this.initialSize,
    required this.minSize,
    required this.maxSize,
    required this.builder,
  });

  final double initialSize;
  final double minSize;
  final double maxSize;
  final Widget Function(BuildContext context, ScrollController scrollController)
  builder;

  @override
  State<_HapticDismissDrag> createState() => _HapticDismissDragState();
}

class _HapticDismissDragState extends State<_HapticDismissDrag> {
  bool _armed = true;

  bool _onNotification(DraggableScrollableNotification notification) {
    final atThreshold = notification.extent <= notification.minExtent;
    if (atThreshold && _armed) {
      _armed = false;
      HapticFeedback.mediumImpact();
    } else if (!atThreshold) {
      _armed = true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) =>
      NotificationListener<DraggableScrollableNotification>(
        onNotification: _onNotification,
        child: DraggableScrollableSheet(
          initialChildSize: widget.initialSize,
          minChildSize: widget.minSize,
          maxChildSize: widget.maxSize,
          builder: (context, scrollController) => SheetSurface(
            side: FLayout.btt,
            child: widget.builder(context, scrollController),
          ),
        ),
      );
}
