import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';
import 'package:reader_documents/features/documents/presentation/actions/document_commands.dart';
import 'package:reader_documents/features/documents/presentation/actions/document_search_items.dart';
import 'package:reader_documents/features/settings/presentation/theme_commands.dart';
import 'package:reader_documents/l10n/app_localizations.dart';

abstract final class AppCommandLauncher {
  static void show(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    AppCommandPalette.show(
      context: context,
      hint: l10n.searchHint,
      recentLabel: l10n.searchRecentCommands,
      noResultsLabel: l10n.searchNoResults,
      groups: [
        AppCommandGroup(
          label: l10n.homeRecentTitle,
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
          items: DocumentCommands.items(context, ref),
        ),
        AppCommandGroup(
          label: l10n.themeSectionTitle,
          items: ThemeCommands.items(context, ref),
        ),
      ],
    );
  }
}
