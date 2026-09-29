import 'package:flutter/widgets.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';

/// A single labeled number in [HomeStatsSection] (e.g. document count).
class HomeStatTile extends StatelessWidget {
  const HomeStatTile({
    required this.icon,
    required this.label,
    required this.value,
    super.key,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => AppCard(
    padding: const EdgeInsets.all(AppSpacing.md),
    child: Row(
      spacing: AppSpacing.sm,
      children: [
        Icon(icon, size: 20, color: AppColors.accent(context)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                value,
                variant: AppTextVariant.subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              AppText(
                label,
                variant: AppTextVariant.caption,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
