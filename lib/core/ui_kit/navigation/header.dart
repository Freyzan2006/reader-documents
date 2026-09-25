import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

import '../controls/icon_button.dart';
import '../data_display/card.dart';
import '../data_display/text.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_typography.dart';

class AppHeader extends StatelessWidget {
  static const double height = 64;

  static double topInset(BuildContext context) =>
      MediaQuery.paddingOf(context).top + height;

  const AppHeader({
    required this.title,
    this.onMenuTap,
    this.actionLabel,
    this.actionIcon,
    this.onActionTap,
    super.key,
  });

  final String title;
  final VoidCallback? onMenuTap;
  final String? actionLabel;
  final IconData? actionIcon;
  final VoidCallback? onActionTap;

  @override
  Widget build(BuildContext context) => FHeader.nested(
    style: const FHeaderStyleDelta.delta(
      constraints: BoxConstraints(minHeight: height, maxHeight: height),
    ),
    title: AppCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      child: AppText(title, variant: AppTextVariant.title),
    ),
    prefixes: [
      if (onMenuTap != null)
        AppIconButton(icon: FLucideIcons.menu, onPressed: onMenuTap!),
    ],
    suffixes: [
      if (actionIcon != null && onActionTap != null)
        AppIconButton(icon: actionIcon!, onPressed: onActionTap!)
      else if (actionLabel != null && onActionTap != null)
        _PillButton(label: actionLabel!, onPressed: onActionTap!),
    ],
  );
}

class _PillButton extends StatelessWidget {
  const _PillButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => FTappable(
    onPress: onPressed,
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: context.theme.colors.primary,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        child: Text(
          label,
          style: AppTypography.of(context).body.sm.copyWith(
            color: context.theme.colors.primaryForeground,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    ),
  );
}
