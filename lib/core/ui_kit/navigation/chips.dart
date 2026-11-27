import 'package:flutter/widgets.dart';

import '../primitives/tappable.dart';
import '../theme/app_tokens.dart';
import '../tokens/app_radius.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_typography.dart';

class AppChip extends StatelessWidget {
  const AppChip({
    required this.label,
    required this.selected,
    required this.onPressed,
    this.icon,
    this.count,
    super.key,
  });

  static const _height = 32.0;

  final String label;
  final bool selected;
  final VoidCallback? onPressed;
  final IconData? icon;
  final int? count;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final palette = tokens.palette;
    final foreground = selected ? palette.onInk : palette.ink2;
    final icon = this.icon;
    final count = this.count;

    return AppTappable(
      onPressed: onPressed,
      selected: selected,
      semanticsLabel: count == null ? label : '$label, $count',
      excludeChildSemantics: true,
      child: AnimatedContainer(
        duration: tokens.motion.quick,
        height: _height,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        decoration: BoxDecoration(
          color: selected ? palette.ink : palette.sheet,
          borderRadius: AppRadii.pill,
          border: Border.all(color: selected ? palette.ink : palette.rule),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 6,
          children: [
            if (icon != null) Icon(icon, size: 16, color: foreground),
            Text(
              label,
              maxLines: 1,
              style: AppTextStyles.label.copyWith(
                fontSize: 13,
                height: 18 / 13,
                color: foreground,
              ),
            ),
            if (count != null)
              Text(
                '$count',
                style: AppTextStyles.overline.copyWith(
                  color: selected
                      ? palette.onInk.withValues(alpha: 0.7)
                      : palette.ink3,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class AppChipBar extends StatelessWidget {
  const AppChipBar({
    required this.children,
    this.padding = const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
    super.key,
  });

  final List<Widget> children;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    padding: padding,
    child: Row(spacing: AppSpacing.sm, children: children),
  );
}
