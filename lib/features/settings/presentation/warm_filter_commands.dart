import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';
import 'package:reader_documents/features/settings/application/settings_providers.dart';
import 'package:reader_documents/l10n/app_localizations.dart';

/// Shared warm-filter toggle so every entry point gives the same feedback.
abstract final class WarmFilterCommands {
  static void toggle(BuildContext context, WidgetRef ref) {
    final enabled =
        !(ref.read(settingsProvider).value?.warmReadingFilter ?? false);
    ref.read(settingsProvider.notifier).setWarmReadingFilter(enabled);

    final l10n = AppLocalizations.of(context)!;
    AppToast.show(
      context: context,
      title: Text(
        enabled ? l10n.warmFilterEnabledToast : l10n.warmFilterDisabledToast,
      ),
    );
  }
}
