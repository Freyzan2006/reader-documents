import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reader_documents/core/config/app_brand.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';
import 'package:reader_documents/features/documents/data/models/document_file.dart';
import 'package:reader_documents/features/documents/presentation/actions/document_commands.dart';
import 'package:reader_documents/features/documents/presentation/menu/continue_reading_menu_section.dart';
import 'package:reader_documents/features/documents/presentation/menu/import_document_menu_button.dart';
import 'package:reader_documents/features/documents/presentation/menu/recent_documents_menu_section.dart';
import 'package:reader_documents/features/settings/presentation/menu/theme_mode_switcher.dart';
import 'package:reader_documents/l10n/app_localizations.dart';

import 'app_nav_tab.dart';
import 'navigation_providers.dart';
import 'side_menu_brand.dart';
import 'side_menu_nav.dart';

class AppSideMenuActions {
  const AppSideMenuActions({
    required this.context,
    required this.ref,
    required this.controller,
  });

  final BuildContext context;
  final WidgetRef ref;
  final AppSidePanelController controller;

  Future<void> openDocument(DocumentFile file) async {
    await controller.close();
    if (!context.mounted) return;
    await DocumentCommands.open(context, ref, file);
  }

  Future<void> importDocument() async {
    await controller.close();
    await DocumentCommands.importDocument(ref);
  }

  Future<void> openFavorites() async {
    await controller.close();
    if (!context.mounted) return;
    await DocumentCommands.openFavorites(context);
  }

  Future<void> goTo(AppNavDestination destination) async {
    ref.read(currentNavDestinationProvider.notifier).state = destination;
    await controller.close();
  }
}

abstract final class AppSideMenu {
  static const _panelFraction = 0.86;

  static void show(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    AppSidePanel.show(
      context: context,
      side: AppEdge.left,
      panelFraction: _panelFraction,
      dismissLabel: l10n.menuTitle,
      builder: (_, controller) {
        final actions = AppSideMenuActions(
          context: context,
          ref: ref,
          controller: controller,
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SideMenuBrand(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.sm,
                  0,
                  AppSpacing.sm,
                  AppSpacing.lg,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: AppSpacing.xl,
                  children: [
                    SideMenuNav(
                      onDestination: actions.goTo,
                      onFavorites: actions.openFavorites,
                    ),
                    ContinueReadingMenuSection(onOpen: actions.openDocument),
                    RecentDocumentsMenuSection(onOpen: actions.openDocument),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                0,
                AppSpacing.lg,
                AppSpacing.md,
              ),
              child: ImportDocumentMenuButton(
                onPressed: actions.importDocument,
              ),
            ),
            const AppDivider(),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.lg,
                AppSpacing.lg,
              ),
              child: Row(
                children: [
                  const ThemeModeSwitcher(),
                  const Spacer(),
                  AppText('v${AppBrand.version}', variant: AppTextVariant.meta),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
