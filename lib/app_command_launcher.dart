import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';
import 'package:reader_documents/features/documents/presentation/document_commands.dart';
import 'package:reader_documents/features/settings/presentation/theme_commands.dart';
import 'package:reader_documents/l10n/app_localizations.dart';

abstract final class AppCommandLauncher {
  static void show(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    AppCommandPalette.show(
      context: context,
      groups: [
        AppCommandGroup(
          label: l10n.documentsTitle,
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
