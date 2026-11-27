import 'package:flutter/widgets.dart';

import '../tokens/app_spacing.dart';
import '../theme/app_tokens.dart';
import '../tokens/app_icons.dart';

class AppDismissible extends StatelessWidget {
  const AppDismissible({
    required this.itemKey,
    required this.child,
    required this.onDismissed,
    this.confirmDismiss,
    this.direction = DismissDirection.endToStart,
    this.background,
    this.secondaryBackground,
    super.key,
  });

  final Key itemKey;
  final Widget child;
  final VoidCallback onDismissed;

  final Future<bool> Function(DismissDirection direction)? confirmDismiss;
  final DismissDirection direction;
  final Widget? background;
  final Widget? secondaryBackground;

  @override
  Widget build(BuildContext context) => Dismissible(
    key: itemKey,
    direction: direction,
    confirmDismiss: confirmDismiss,
    movementDuration: context.tokens.motion.exit,
    resizeDuration: context.tokens.motion.layoutChange,
    onDismissed: (_) => onDismissed(),
    background:
        background ??
        AppDismissibleAction(
          icon: AppIcons.trash,
          color: context.tokens.palette.danger,
          foregroundColor: context.tokens.palette.onDanger,
          alignment: Alignment.centerLeft,
        ),
    secondaryBackground:
        secondaryBackground ??
        AppDismissibleAction(
          icon: AppIcons.trash,
          color: context.tokens.palette.danger,
          foregroundColor: context.tokens.palette.onDanger,
          alignment: Alignment.centerRight,
        ),
    child: child,
  );
}

class AppDismissibleAction extends StatelessWidget {
  const AppDismissibleAction({
    required this.icon,
    required this.color,
    required this.foregroundColor,
    required this.alignment,
    super.key,
  });

  final IconData icon;
  final Color color;
  final Color foregroundColor;
  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(color: color),
    child: Align(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: Icon(icon, color: foregroundColor),
      ),
    ),
  );
}
