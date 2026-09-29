import 'package:flutter/widgets.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';

/// A section header (icon + title, optional trailing action) followed by its
/// content — the shape every Home section shares, pulled out once instead of
/// repeated per section.
class HomeSection extends StatelessWidget {
  const HomeSection({
    required this.title,
    required this.icon,
    required this.child,
    this.trailing,
    super.key,
  });

  final String title;
  final IconData icon;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    spacing: AppSpacing.sm,
    children: [
      Row(
        spacing: AppSpacing.xs,
        children: [
          Icon(icon, size: 18, color: AppColors.of(context).mutedForeground),
          Expanded(child: AppText(title, variant: AppTextVariant.body)),
          ?trailing,
        ],
      ),
      child,
    ],
  );
}
