import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';
import 'package:reader_documents/features/documents/presentation/actions/document_commands.dart';
import 'package:reader_documents/features/documents/presentation/actions/document_search_items.dart';
import 'package:reader_documents/features/settings/presentation/theme_commands.dart';
import 'package:reader_documents/l10n/app_localizations.dart';

import 'navigation_commands.dart';

abstract final class AppCommandLauncher {
  static void show(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    AppCommandPalette.show(
      context: context,
      hint: l10n.searchHint,
      recentLabel: l10n.menuRecentTitle,
      noResultsLabel: l10n.searchNoResults,
      clearLabel: l10n.clear,
      noResultsAction: AppCommandItem(
        label: l10n.importDocument,
        icon: AppIcons.upload,
        onSelect: () => DocumentCommands.importDocument(ref),
      ),
      groups: [
        AppCommandGroup(
          label: l10n.documentsTitle,
          mode: AppCommandGroupMode.idle,
          items: DocumentSearchItems.recent(context, ref),
        ),
        AppCommandGroup(
          label: l10n.documentsTitle,
          mode: AppCommandGroupMode.search,
          items: DocumentSearchItems.all(context, ref),
        ),
        AppCommandGroup(
          label: l10n.searchActionsTitle,
          items: [
            ...DocumentCommands.items(context, ref),
            ...ThemeCommands.items(context, ref),
          ],
        ),
        AppCommandGroup(
          label: l10n.searchGoToTitle,
          items: NavigationCommands.items(context, ref),
        ),
      ],
    );
  }
}
