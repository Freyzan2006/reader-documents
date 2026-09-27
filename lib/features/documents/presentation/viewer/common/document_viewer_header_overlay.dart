import 'package:flutter/widgets.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';

class DocumentViewerHeaderOverlay extends StatelessWidget {
  const DocumentViewerHeaderOverlay({
    required this.visible,
    required this.child,
    this.topSafeArea = true,
    super.key,
  });

  final bool visible;
  final Widget child;

  /// Whether to reserve space for the physical top inset (status bar/notch).
  /// Set to `false` when this overlay is itself displayed rotated — the
  /// device's real notch isn't on whichever edge the overlay's own "top"
  /// now renders along, so reserving it would just waste space.
  final bool topSafeArea;

  static const _rotatedTopGap = AppSpacing.sm;

  @override
  Widget build(BuildContext context) => Positioned(
    top: 0,
    left: 0,
    right: 0,
    child: AppFade(
      visible: visible,
      child: SafeArea(
        top: topSafeArea,
        bottom: false,
        child: Padding(
          padding: EdgeInsets.only(top: topSafeArea ? 0 : _rotatedTopGap),
          child: SizedBox(
            height: AppHeader.height,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: child,
            ),
          ),
        ),
      ),
    ),
  );
}
