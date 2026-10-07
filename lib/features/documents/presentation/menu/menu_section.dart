import 'package:flutter/widgets.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';

class MenuSection extends StatelessWidget {
  const MenuSection({
    required this.title,
    required this.icon,
    required this.child,
    super.key,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    spacing: AppSpacing.sm,
    children: [
      Row(
        spacing: AppSpacing.xs,
        children: [
          Icon(icon, size: 16, color: AppColors.of(context).mutedForeground),
          Expanded(child: AppText(title, variant: AppTextVariant.caption)),
        ],
      ),
      child,
    ],
  );
}
