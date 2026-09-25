import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart' show FBuildContext, FTappable;

import '../tokens/app_borders.dart';
import '../tokens/app_radius.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_typography.dart';

class AppBottomNavItem {
  const AppBottomNavItem({required this.icon, required this.label});

  final IconData icon;
  final String label;
}

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    required this.items,
    required this.currentIndex,
    required this.onChanged,
    super.key,
  });

  static const double height = 56;

  static double bottomInset(BuildContext context) =>
      _bottomMargin(context) + height;

  static double _bottomMargin(BuildContext context) =>
      MediaQuery.paddingOf(context).bottom < AppSpacing.md
      ? AppSpacing.md
      : MediaQuery.paddingOf(context).bottom;

  final List<AppBottomNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    minimum: const EdgeInsets.fromLTRB(
      AppSpacing.lg,
      0,
      AppSpacing.lg,
      AppSpacing.md,
    ),
    child: ClipRRect(
      borderRadius: AppRadius.of(context).xl2,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: context.theme.colors.secondary.withValues(alpha: 0.7),
            border: AppBorders.all(context),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                for (final (index, item) in items.indexed)
                  Expanded(
                    child: _AppBottomNavTab(
                      item: item,
                      selected: index == currentIndex,
                      onPress: () => onChanged(index),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class _AppBottomNavTab extends StatelessWidget {
  const _AppBottomNavTab({
    required this.item,
    required this.selected,
    required this.onPress,
  });

  final AppBottomNavItem item;
  final bool selected;
  final VoidCallback onPress;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;

    return FTappable(
      behavior: HitTestBehavior.opaque,
      selected: selected,
      semanticsLabel: item.label,
      onPress: onPress,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        child: Center(
          heightFactor: 1,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 4,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: selected ? colors.primary : null,
                  borderRadius: AppRadius.of(context).pill,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs,
                  ),
                  child: Icon(
                    item.icon,
                    size: 22,
                    color: selected
                        ? colors.primaryForeground
                        : colors.mutedForeground,
                  ),
                ),
              ),
              Text(
                item.label,
                style: AppTypography.of(context).body.xs3.copyWith(
                  color: selected ? colors.primary : colors.mutedForeground,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
