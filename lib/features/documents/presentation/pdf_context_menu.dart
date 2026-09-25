import 'package:flutter/widgets.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';

class PdfContextMenuAction {
  const PdfContextMenuAction({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final Widget icon;
  final VoidCallback? onPressed;
}

class PdfContextMenu extends StatelessWidget {
  const PdfContextMenu({required this.actions, super.key});

  final List<PdfContextMenuAction> actions;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: AppRadius.of(context).lg,
        border: AppBorders.all(context),
        boxShadow: [
          BoxShadow(
            color: colors.foreground.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xs),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: AppSpacing.xs,
          children: [
            for (final action in actions)
              AppTappable(
                onPressed: action.onPressed,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  child: Semantics(label: action.label, child: action.icon),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
