import 'package:flutter/widgets.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';

enum DocumentViewerBarEdge { top, bottom }

class DocumentViewerHeaderOverlay extends StatelessWidget {
  const DocumentViewerHeaderOverlay({
    required this.visible,
    required this.child,
    this.topSafeArea = true,
    this.edge = DocumentViewerBarEdge.top,
    super.key,
  });

  final bool visible;
  final Widget child;
  final bool topSafeArea;
  final DocumentViewerBarEdge edge;

  @override
  Widget build(BuildContext context) {
    final top = edge == DocumentViewerBarEdge.top;
    return Positioned(
      top: top ? 0 : null,
      bottom: top ? null : 0,
      left: 0,
      right: 0,
      child: AppFade(
        visible: visible,
        child: AppBarSurface(
          divider: top ? AppBarEdge.bottom : AppBarEdge.top,
          child: SafeArea(
            top: top && topSafeArea,
            bottom: !top && topSafeArea,
            child: top
                ? SizedBox(
                    height: AppHeader.height,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                      ),
                      child: child,
                    ),
                  )
                : child,
          ),
        ),
      ),
    );
  }
}
