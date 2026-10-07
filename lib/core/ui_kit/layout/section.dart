import 'package:flutter/widgets.dart';

import '../data_display/text.dart';
import '../tokens/app_colors.dart';
import '../tokens/app_spacing.dart';

enum AppSectionVariant { standard, compact }

class AppSection extends StatelessWidget {
  const AppSection({
    required this.title,
    required this.child,
    this.icon,
    this.hint,
    this.trailing,
    this.variant = AppSectionVariant.standard,
    super.key,
  });

  final String title;
  final Widget child;
  final IconData? icon;
  final String? hint;
  final Widget? trailing;
  final AppSectionVariant variant;

  bool get _compact => variant == AppSectionVariant.compact;

  @override
  Widget build(BuildContext context) {
    final muted = AppColors.of(context).mutedForeground;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppSpacing.sm,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: AppSpacing.xs,
          children: [
            Row(
              spacing: AppSpacing.xs,
              children: [
                if (icon != null)
                  Icon(icon, size: _compact ? 16 : 18, color: muted),
                Expanded(
                  child: AppText(
                    title,
                    variant: _compact
                        ? AppTextVariant.caption
                        : AppTextVariant.subtitle,
                  ),
                ),
                ?trailing,
              ],
            ),
            if (hint != null) AppText(hint!, variant: AppTextVariant.caption),
          ],
        ),
        child,
      ],
    );
  }
}
