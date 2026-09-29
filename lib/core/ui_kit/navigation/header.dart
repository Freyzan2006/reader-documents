import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

import '../controls/icon_button.dart';
import '../data_display/card.dart';
import '../data_display/text.dart';
import '../overlay/tooltip.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_typography.dart';

class AppHeader extends StatelessWidget {
  static const double height = 64;

  static double topInset(BuildContext context) =>
      MediaQuery.paddingOf(context).top + height;

  const AppHeader({
    required this.title,
    this.titleTooltip,
    this.onMenuTap,
    this.actionLabel,
    this.actionIcon,
    this.onActionTap,
    super.key,
  });

  final String title;

  /// Shown on hover/long-press of the title (e.g. the full brand name
  /// behind a shortened logo/title).
  final String? titleTooltip;

  final VoidCallback? onMenuTap;
  final String? actionLabel;
  final IconData? actionIcon;
  final VoidCallback? onActionTap;

  @override
  Widget build(BuildContext context) {
    final titleCard = AppCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      child: AppText(title, variant: AppTextVariant.title),
    );

    return Stack(
      children: [
        FHeader.nested(
          style: const FHeaderStyleDelta.delta(
            constraints: BoxConstraints(minHeight: height, maxHeight: height),
          ),
          title: titleTooltip == null
              ? titleCard
              : AppTooltip(message: titleTooltip, child: titleCard),
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
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: IgnorePointer(
            child: Container(
              height: 16,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    context.theme.colors.foreground.withValues(alpha: 0.2),
                    context.theme.colors.foreground.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
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
