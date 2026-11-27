import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';
import 'package:reader_documents/features/documents/application/documents_providers.dart';
import 'package:reader_documents/l10n/app_localizations.dart';

import 'app_nav_tab.dart';
import 'navigation_providers.dart';

class SideMenuNav extends ConsumerWidget {
  const SideMenuNav({
    required this.onDestination,
    required this.onFavorites,
    super.key,
  });

  final ValueChanged<AppNavDestination> onDestination;
  final VoidCallback onFavorites;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final current = ref.watch(currentNavDestinationProvider);
    final documents = ref.watch(documentStatsProvider).value?.count;
    final favorites = ref.watch(favoriteDocumentsProvider).value?.length ?? 0;

    AppSideNavItem destination(
      AppNavDestination target,
      IconData icon,
      String label, {
      Widget? trailing,
    }) => AppSideNavItem(
      icon: icon,
      label: label,
      selected: current == target,
      trailing: trailing,
      onPressed: () => onDestination(target),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 2,
      children: [
        destination(AppNavDestination.home, AppIcons.house, l10n.navHome),
        destination(
          AppNavDestination.documents,
          AppIcons.fileText,
          l10n.navDocuments,
          trailing: documents == null
              ? null
              : AppText('$documents', variant: AppTextVariant.meta),
        ),
        AppSideNavItem(
          icon: AppIcons.star,
          label: l10n.homeFavoritesTitle,
          onPressed: onFavorites,
          trailing: favorites == 0
              ? null
              : AppBadge(
                  variant: AppBadgeVariant.secondary,
                  child: Text('$favorites'),
                ),
        ),
        destination(
          AppNavDestination.settings,
          AppIcons.settings,
          l10n.navSettings,
        ),
      ],
    );
  }
}
