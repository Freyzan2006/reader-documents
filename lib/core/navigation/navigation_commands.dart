import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';
import 'package:reader_documents/features/documents/application/documents_providers.dart';
import 'package:reader_documents/features/documents/presentation/actions/document_commands.dart';
import 'package:reader_documents/features/settings/presentation/appearance_screen.dart';
import 'package:reader_documents/l10n/app_localizations.dart';

import 'app_nav_tab.dart';
import 'navigation_providers.dart';

abstract final class NavigationCommands {
  static List<AppCommandItem> items(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final current = ref.read(currentNavDestinationProvider);
    final favorites = ref.read(favoriteDocumentsProvider).value?.length ?? 0;
    final documents = ref.read(documentStatsProvider).value?.count;

    void goTo(AppNavDestination destination) =>
        ref.read(currentNavDestinationProvider.notifier).state = destination;

    return [
      if (current != AppNavDestination.home)
        AppCommandItem(
          label: l10n.navHome,
          icon: AppIcons.house,
          onSelect: () => goTo(AppNavDestination.home),
        ),
      if (current != AppNavDestination.documents)
        AppCommandItem(
          label: l10n.navDocuments,
          icon: AppIcons.fileText,
          value: documents?.toString(),
          onSelect: () => goTo(AppNavDestination.documents),
        ),
      AppCommandItem(
        label: l10n.homeFavoritesTitle,
        icon: AppIcons.star,
        value: favorites > 0 ? '$favorites' : null,
        onSelect: () => DocumentCommands.openFavorites(context),
      ),
      if (current != AppNavDestination.settings)
        AppCommandItem(
          label: l10n.navSettings,
          icon: AppIcons.settings,
          onSelect: () => goTo(AppNavDestination.settings),
        ),
      AppCommandItem(
        label: l10n.appearanceTitle,
        icon: AppIcons.palette,
        onSelect: () => Navigator.of(context)
            .push(AppPageRoute<void>(builder: (_) => const AppearanceScreen())),
      ),
    ];
  }
}
