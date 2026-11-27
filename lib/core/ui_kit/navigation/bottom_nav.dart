import 'package:flutter/widgets.dart';

import '../primitives/bar_surface.dart';
import '../primitives/tappable.dart';
import '../theme/app_tokens.dart';
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

  static const double height = 64;

  static double bottomInset(BuildContext context) =>
      MediaQuery.paddingOf(context).bottom + height;

  final List<AppBottomNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) => AppBarSurface(
    divider: AppBarEdge.top,
    child: SafeArea(
      top: false,
      child: SizedBox(
        height: height,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          child: Row(
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
  );
}

class _AppBottomNavTab extends StatelessWidget {
  const _AppBottomNavTab({
    required this.item,
    required this.selected,
    required this.onPress,
  });

  static const _pillWidth = 56.0;
  static const _pillHeight = 30.0;
  static const _iconSize = 22.0;

  final AppBottomNavItem item;
  final bool selected;
  final VoidCallback onPress;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final palette = tokens.palette;

    return AppTappable(
      onPressed: onPress,
      selected: selected,
      semanticsLabel: item.label,
      excludeChildSemantics: true,
      pressedOpacity: 1,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: AppSpacing.xs,
        children: [
          AnimatedContainer(
            duration: tokens.motion.quick,
            curve: Curves.easeOut,
            width: _pillWidth,
            height: _pillHeight,
            decoration: BoxDecoration(
              color: selected ? palette.ink : const Color(0x00000000),
              borderRadius: AppRadii.pill,
            ),
            child: Icon(
              item.icon,
              size: _iconSize,
              color: selected ? palette.onInk : palette.ink3,
            ),
          ),
          Text(
            item.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.caption.copyWith(
              fontSize: 12,
              height: 16 / 12,
              color: selected ? palette.ink : palette.ink3,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
