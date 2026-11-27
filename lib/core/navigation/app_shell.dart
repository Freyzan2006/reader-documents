import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';
import 'package:reader_documents/features/documents/application/documents_providers.dart';
import 'package:reader_documents/features/documents/presentation/list/document_selection_aware_header.dart';
import 'package:reader_documents/features/documents/presentation/list/document_selection_header.dart';
import 'package:reader_documents/l10n/app_localizations.dart';

import 'app_command_launcher.dart';
import 'app_nav_tab.dart';
import 'app_side_menu.dart';
import 'navigation_providers.dart';

class AppShell extends ConsumerWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final tabs = AppNavTabs.all(l10n);
    final destination = ref.watch(currentNavDestinationProvider);
    final index = tabs.indexWhere((tab) => tab.destination == destination);

    ref.listen(
      currentNavDestinationProvider,
      (_, _) => ref.read(documentSelectionProvider.notifier).clear(),
    );

    return AppScaffold(
      contentKey: destination,
      header: DocumentSelectionAwareHeader(
        normal: AppHeader(
          title: tabs[index].label,
          collapsible: destination != AppNavDestination.home,
          onMenuTap: () => AppSideMenu.show(context, ref),
          menuLabel: l10n.menuTitle,
          actionIcon: AppIcons.search,
          actionLabel: l10n.homeQuickActionSearch,
          onActionTap: () => AppCommandLauncher.show(context, ref),
        ),
      ),
      footer: DocumentSelectionAwareFooter(
        normal: AppBottomNav(
          currentIndex: index,
          onChanged: (next) =>
              ref.read(currentNavDestinationProvider.notifier).state =
                  tabs[next].destination,
          items: [
            for (final tab in tabs)
              AppBottomNavItem(icon: tab.icon, label: tab.label),
          ],
        ),
      ),
      child: IndexedStack(
        index: index,
        children: [
          for (final (tabIndex, tab) in tabs.indexed)
            HeroMode(
              enabled: tabIndex == index,
              child: TickerMode(enabled: tabIndex == index, child: tab.screen),
            ),
        ],
      ),
    );
  }
}
