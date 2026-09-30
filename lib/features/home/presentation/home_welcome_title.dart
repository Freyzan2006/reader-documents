import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reader_documents/core/ui/welcome_title.dart';
import 'package:reader_documents/features/settings/application/settings_providers.dart';
import 'package:reader_documents/l10n/app_localizations.dart';

/// The Home page heading — a greeting, personalized with the profile's first
/// name once one has been set in Settings.
class HomeWelcomeTitle extends ConsumerWidget {
  const HomeWelcomeTitle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final firstName =
        ref.watch(settingsProvider).value?.profile.firstName ?? '';

    return WelcomeTitle(
      title: l10n.homeWelcome,
      personalizedTitle: firstName.isEmpty
          ? null
          : l10n.homeWelcomeName(firstName),
    );
  }
}
