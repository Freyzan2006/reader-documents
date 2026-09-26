import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

import '../tokens/app_spacing.dart';
import 'text.dart';

class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    required this.message,
    this.icon,
    this.description,
    this.action,
    super.key,
  });

  final IconData? icon;
  final String message;
  final String? description;
  final Widget? action;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
    child: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: AppSpacing.sm,
        children: [
          if (icon != null)
            Icon(icon, size: 40, color: context.theme.colors.mutedForeground),
          AppText(
            message,
            variant: AppTextVariant.caption,
            textAlign: TextAlign.center,
          ),
          if (description != null)
            AppText(
              description!,
              variant: AppTextVariant.caption,
              textAlign: TextAlign.center,
            ),
          ?action,
        ],
      ),
    ),
  );
}
