import 'package:flutter/widgets.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';

import '../contract/document_viewer_controller.dart';

class DocumentViewerZoomControls extends StatelessWidget {
  const DocumentViewerZoomControls({required this.controller, super.key});

  static const _step = 0.1;
  static const _valueDiameter = 36.0;

  final DocumentViewerController? controller;

  @override
  Widget build(BuildContext context) {
    final controller = this.controller;
    if (controller == null || !controller.supportsZoom) {
      return const SizedBox.shrink();
    }

    final percent = (controller.zoom * 100).round();

    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: AppSpacing.xs,
      children: [
        AppIconButton(
          icon: AppIcons.plus,
          onPressed: controller.zoom < controller.maxZoom
              ? () => controller.setZoom(controller.zoom + _step)
              : null,
        ),
        SizedBox(
          width: _valueDiameter,
          height: _valueDiameter,
          child: ClipOval(
            child: AppCard(
              padding: EdgeInsets.zero,
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xs),
                    child: AppText('$percent%', variant: AppTextVariant.title),
                  ),
                ),
              ),
            ),
          ),
        ),
        AppIconButton(
          icon: AppIcons.minus,
          onPressed: controller.zoom > controller.minZoom
              ? () => controller.setZoom(controller.zoom - _step)
              : null,
        ),
      ],
    );
  }
}
