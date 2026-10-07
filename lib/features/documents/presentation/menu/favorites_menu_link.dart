import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';
import 'package:reader_documents/features/documents/application/documents_providers.dart';
import 'package:reader_documents/l10n/app_localizations.dart';

class FavoritesMenuLink extends ConsumerWidget {
  const FavoritesMenuLink({required this.onTap, super.key});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(favoriteDocumentsProvider).value?.length;
    final colors = AppColors.of(context);

    return AppTappable(
      onPressed: onTap,
      child: AppCard(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          spacing: AppSpacing.md,
          children: [
            Icon(AppIcons.star, size: 20, color: AppColors.warning(context)),
            Expanded(
              child: AppText(
                AppLocalizations.of(context)!.homeFavoritesTitle,
                variant: AppTextVariant.subtitle,
              ),
            ),
            if (count != null && count > 0)
              AppBadge(
                variant: AppBadgeVariant.secondary,
                child: Text('$count'),
              ),
            Icon(AppIcons.arrowRight, size: 18, color: colors.mutedForeground),
          ],
        ),
      ),
    );
  }
}
