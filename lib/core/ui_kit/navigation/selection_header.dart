import 'package:flutter/widgets.dart';

import '../controls/icon_button.dart';
import '../primitives/bar_surface.dart';
import '../primitives/tappable.dart';
import '../theme/app_tokens.dart';
import '../tokens/app_icons.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_typography.dart';
import 'bottom_nav.dart';
import 'header.dart';

class AppSelectionAction {
  const AppSelectionAction({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.destructive = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final bool destructive;
}

class AppSelectionHeader extends StatelessWidget {
  const AppSelectionHeader({
    required this.title,
    required this.closeLabel,
    required this.onClose,
    this.actions = const [],
    super.key,
  });

  final String title;
  final String closeLabel;
  final VoidCallback onClose;
  final List<AppSelectionAction> actions;

  @override
  Widget build(BuildContext context) {
    final palette = context.tokens.palette;

    return ColoredBox(
      color: palette.ink,
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: AppHeader.height,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            child: Row(
              spacing: AppSpacing.xs,
              children: [
                AppIconButton(
                  icon: AppIcons.x,
                  onPressed: onClose,
                  semanticsLabel: closeLabel,
                  color: palette.onInk,
                ),
                Expanded(
                  child: Semantics(
                    liveRegion: true,
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.subtitle.copyWith(
                        color: palette.onInk,
                      ),
                    ),
                  ),
                ),
                for (final action in actions)
                  AppIconButton(
                    icon: action.icon,
                    onPressed: action.onPressed,
                    semanticsLabel: action.label,
                    color: action.destructive
                        ? palette.dangerSoft
                        : palette.onInk,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AppSelectionActionBar extends StatelessWidget {
  const AppSelectionActionBar({required this.actions, super.key});

  final List<AppSelectionAction> actions;

  @override
  Widget build(BuildContext context) {
    final palette = context.tokens.palette;
    return AppBarSurface(
      divider: AppBarEdge.top,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: AppBottomNav.height,
          child: Row(
            children: [
              for (final action in actions)
                Expanded(
                  child: AppTappable(
                    onPressed: action.onPressed,
                    semanticsLabel: action.label,
                    excludeChildSemantics: true,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      spacing: AppSpacing.xs,
                      children: [
                        Icon(
                          action.icon,
                          size: 22,
                          color: action.destructive
                              ? palette.danger
                              : palette.ink,
                        ),
                        Text(
                          action.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.caption.copyWith(
                            fontSize: 12,
                            height: 16 / 12,
                            fontWeight: FontWeight.w500,
                            color: action.destructive
                                ? palette.danger
                                : palette.ink,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
