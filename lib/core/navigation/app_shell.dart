import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reader_documents/core/config/app_brand.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';
import 'package:reader_documents/l10n/app_localizations.dart';

import 'app_command_launcher.dart';
import 'app_nav_tab.dart';
import 'navigation_providers.dart';

class AppShell extends ConsumerWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final tabs = AppNavTabs.all(l10n);
    final destination = ref.watch(currentNavDestinationProvider);
    final index = tabs.indexWhere((tab) => tab.destination == destination);

    return AppScaffold(
      header: AppHeader(
        title: AppBrand.shortName,
        onMenuTap: () => _openMenu(context, ref, tabs, l10n),
        actionIcon: AppIcons.command,
        onActionTap: () => AppCommandLauncher.show(context, ref),
      ),
      footer: AppBottomNav(
        currentIndex: index,
        onChanged: (next) =>
            ref.read(currentNavDestinationProvider.notifier).state =
                tabs[next].destination,
        items: [
          for (final tab in tabs)
            AppBottomNavItem(icon: tab.icon, label: tab.label),
        ],
      ),
      child: IndexedStack(
        index: index,
        children: [for (final tab in tabs) tab.screen],
      ),
    );
  }

  void _openMenu(
    BuildContext context,
    WidgetRef ref,
    List<AppNavTab> tabs,
    AppLocalizations l10n,
  ) {
    AppSidePanel.show(
      context: context,
      builder: (context, controller) => Column(
        children: [
          AppSidePanelHeader(title: l10n.menuTitle, onClose: controller.close),
          AppSidePanelContent(
            child: AppList(
              items: [
                for (final tab in tabs)
                  AppListItem(
                    title: tab.label,
                    leading: tab.icon,
                    onTap: () {
                      ref.read(currentNavDestinationProvider.notifier).state =
                          tab.destination;
                      controller.close();
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
