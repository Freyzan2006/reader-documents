import 'package:flutter/widgets.dart';

import '../primitives/tappable.dart';
import '../theme/app_tokens.dart';
import '../tokens/app_radius.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_typography.dart';

class AppSideNavItem extends StatelessWidget {
  const AppSideNavItem({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.selected = false,
    this.trailing,
    super.key,
  });

  static const _height = 44.0;

  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool selected;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final palette = context.tokens.palette;
    final trailing = this.trailing;

    return AppTappable(
      onPressed: onPressed,
      selected: selected,
      semanticsLabel: label,
      child: Container(
        height: _height,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        decoration: BoxDecoration(
          color: selected ? palette.shade : null,
          borderRadius: AppRadii.sm,
        ),
        child: Row(
          spacing: AppSpacing.md,
          children: [
            Icon(icon, size: 20, color: selected ? palette.ink : palette.ink3),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.item.copyWith(
                  color: selected ? palette.ink : palette.ink2,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ),
            ?trailing,
          ],
        ),
      ),
    );
  }
}
