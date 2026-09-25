import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

import '../tokens/app_spacing.dart';

class AppDismissible extends StatelessWidget {
  const AppDismissible({
    required this.itemKey,
    required this.child,
    required this.onDismissed,
    this.confirmDismiss,
    this.direction = DismissDirection.endToStart,
    this.background,
    super.key,
  });

  final Key itemKey;
  final Widget child;
  final VoidCallback onDismissed;
  final Future<bool> Function()? confirmDismiss;
  final DismissDirection direction;
  final Widget? background;

  @override
  Widget build(BuildContext context) => Dismissible(
    key: itemKey,
    direction: direction,
    confirmDismiss: confirmDismiss == null ? null : (_) => confirmDismiss!(),
    onDismissed: (_) => onDismissed(),
    background: background ?? _DefaultBackground(direction: direction),
    child: child,
  );
}

class _DefaultBackground extends StatelessWidget {
  const _DefaultBackground({required this.direction});

  final DismissDirection direction;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(color: context.theme.colors.destructive),
    child: Align(
      alignment: direction == DismissDirection.startToEnd
          ? Alignment.centerLeft
          : Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: Icon(
          FLucideIcons.trash,
          color: context.theme.colors.destructiveForeground,
        ),
      ),
    ),
  );
}
