import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reader_documents/core/navigation/app_nav_tab.dart';
import 'package:reader_documents/core/navigation/navigation_providers.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';
import 'package:reader_documents/features/documents/presentation/actions/document_commands.dart';
import 'package:reader_documents/features/settings/application/settings_providers.dart';
import 'package:reader_documents/l10n/app_localizations.dart';

import 'home_quick_action_button.dart';

/// Import / go-to-search / toggle-warm-filter row.
class HomeQuickActions extends ConsumerWidget {
  const HomeQuickActions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final warmFilterEnabled =
        ref.watch(settingsProvider).value?.warmReadingFilter ?? false;

    return Row(
      spacing: AppSpacing.sm,
      children: [
        Expanded(
          child: HomeQuickActionButton(
            icon: AppIcons.upload,
            label: l10n.homeQuickActionImport,
            onTap: () => DocumentCommands.importDocument(ref),
          ),
        ),
        Expanded(
          child: HomeQuickActionButton(
            icon: AppIcons.search,
            label: l10n.homeQuickActionSearch,
            onTap: () =>
                ref.read(currentNavDestinationProvider.notifier).state =
                    AppNavDestination.documents,
          ),
        ),
        Expanded(
          child: HomeQuickActionButton(
            icon: AppIcons.lamp,
            label: warmFilterEnabled
                ? l10n.pdfMenuWarmFilterOff
                : l10n.pdfMenuWarmFilterOn,
            onTap: () => ref
                .read(settingsProvider.notifier)
                .setWarmReadingFilter(!warmFilterEnabled),
          ),
        ),
      ],
    );
  }
}
