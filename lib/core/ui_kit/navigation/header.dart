import 'package:flutter/widgets.dart';

import '../controls/icon_button.dart';
import '../data_display/text.dart';
import '../layout/scaffold.dart';
import '../overlay/tooltip.dart';
import '../primitives/bar_surface.dart';
import '../primitives/tappable.dart';
import '../theme/app_tokens.dart';
import '../tokens/app_icons.dart';
import '../tokens/app_radius.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_typography.dart';

class AppHeader extends StatelessWidget {
  const AppHeader({
    required this.title,
    this.titleTooltip,
    this.collapsible = false,
    this.onMenuTap,
    this.onBackTap,
    this.backLabel,
    this.menuLabel,
    this.actionLabel,
    this.actionIcon,
    this.onActionTap,
    this.actions = const [],
    super.key,
  });

  static const double height = 56;

  static double topInset(BuildContext context) =>
      MediaQuery.paddingOf(context).top + height;

  final String title;
  final String? titleTooltip;
  final bool collapsible;
  final VoidCallback? onMenuTap;
  final VoidCallback? onBackTap;
  final String? backLabel;
  final String? menuLabel;
  final String? actionLabel;
  final IconData? actionIcon;
  final VoidCallback? onActionTap;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final scrolled = AppScrollScope.of(context);
    final showTitle = !collapsible || scrolled;
    final onBackTap = this.onBackTap;
    final onMenuTap = this.onMenuTap;
    final onActionTap = this.onActionTap;
    final actionIcon = this.actionIcon;
    final actionLabel = this.actionLabel;

    final titleText = AnimatedOpacity(
      opacity: showTitle ? 1 : 0,
      duration: tokens.motion.quick,
      child: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyles.title.copyWith(color: tokens.palette.ink),
      ),
    );

    return AppBarSurface(
      solid: tokens.palette.paper,
      divider: AppBarEdge.bottom,
      showDivider: scrolled,
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: height,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            child: Row(
              spacing: AppSpacing.xs,
              children: [
                if (onBackTap != null)
                  AppIconButton(
                    icon: AppIcons.arrowLeft,
                    onPressed: onBackTap,
                    semanticsLabel: backLabel,
                  ),
                if (onMenuTap != null)
                  AppIconButton(
                    icon: AppIcons.menu,
                    onPressed: onMenuTap,
                    semanticsLabel: menuLabel,
                  ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: onBackTap == null && onMenuTap == null
                          ? AppSpacing.sm
                          : 0,
                    ),
                    child: titleTooltip == null
                        ? titleText
                        : Align(
                            alignment: Alignment.centerLeft,
                            child: AppTooltip(
                              message: titleTooltip,
                              child: titleText,
                            ),
                          ),
                  ),
                ),
                ...actions,
                if (actionIcon != null && onActionTap != null)
                  AppIconButton(
                    icon: actionIcon,
                    onPressed: onActionTap,
                    semanticsLabel: actionLabel,
                  )
                else if (actionLabel != null && onActionTap != null)
                  _PillButton(label: actionLabel, onPressed: onActionTap),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AppLargeTitle extends StatelessWidget {
  const AppLargeTitle({required this.title, this.summary, super.key});

  final String title;
  final String? summary;

  @override
  Widget build(BuildContext context) {
    final summary = this.summary;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.xs,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 2,
        children: [
          Semantics(
            header: true,
            child: AppText(title, variant: AppTextVariant.display),
          ),
          if (summary != null) AppText(summary, variant: AppTextVariant.meta),
        ],
      ),
    );
  }
}

class _PillButton extends StatelessWidget {
  const _PillButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final palette = context.tokens.palette;
    return AppTappable(
      onPressed: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: palette.ink,
          borderRadius: AppRadii.pill,
        ),
        child: Text(
          label,
          style: AppTextStyles.label.copyWith(
            color: palette.onInk,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
