import 'package:flutter/widgets.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';

class DocumentViewerHeaderOverlay extends StatelessWidget {
  const DocumentViewerHeaderOverlay({
    required this.visible,
    required this.child,
    super.key,
  });

  final bool visible;
  final Widget child;

  @override
  Widget build(BuildContext context) => Positioned(
    top: 0,
    left: 0,
    right: 0,
    child: AppFade(
      visible: visible,
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: AppHeader.height,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: child,
          ),
        ),
      ),
    ),
  );
}
