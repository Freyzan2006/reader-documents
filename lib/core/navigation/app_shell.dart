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

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  final Set<int> _visitedTabs = {0};

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final tabs = AppNavTabs.all(l10n);
    final destination = ref.watch(currentNavDestinationProvider);
    final index = tabs.indexWhere((tab) => tab.destination == destination);
    final currentIndex = index < 0 ? 0 : index;
    _visitedTabs.add(currentIndex);

    ref.listen(currentNavDestinationProvider, (_, _) {
      ref.read(documentSelectionProvider.notifier).clear();
    });

    return AppScaffold(
      contentKey: destination,
      header: DocumentSelectionAwareHeader(
        normal: AppHeader(
          title: tabs[currentIndex].label,
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
          currentIndex: currentIndex,
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
        index: currentIndex,
        children: [
          for (final (tabIndex, tab) in tabs.indexed)
            _LazyTab(
              active: tabIndex == currentIndex,
              child: _visitedTabs.contains(tabIndex)
                  ? tab.screen
                  : const SizedBox.shrink(),
            ),
        ],
      ),
    );
  }
}

class _LazyTab extends StatelessWidget {
  const _LazyTab({required this.active, required this.child});

  final bool active;
  final Widget child;

  @override
  Widget build(BuildContext context) => HeroMode(
    enabled: active,
    child: TickerMode(enabled: active, child: child),
  );
}
