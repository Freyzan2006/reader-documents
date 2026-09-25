import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';
import 'package:reader_documents/l10n/app_localizations.dart';

import '../application/settings_providers.dart';
import 'language_settings_card.dart';
import 'profile_settings_card.dart';
import 'theme_settings_card.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final settings = ref.watch(settingsProvider);

    return AppScrollArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppHeader.topInset(context) + AppSpacing.lg,
          AppSpacing.lg,
          AppBottomNav.bottomInset(context) + AppSpacing.lg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(l10n.settingsTitle, variant: AppTextVariant.title),
            const AppGap.lg(),
            settings.when(
              data: (value) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: AppSpacing.lg,
                children: [
                  ProfileSettingsCard(
                    profile: value.profile,
                    onSave: (profile) => ref
                        .read(settingsProvider.notifier)
                        .updateProfile(profile),
                  ),
                  ThemeSettingsCard(
                    themeMode: value.themeMode,
                    onChanged: (mode) =>
                        ref.read(settingsProvider.notifier).setThemeMode(mode),
                  ),
                  LanguageSettingsCard(
                    language: value.language,
                    onChanged: (language) => ref
                        .read(settingsProvider.notifier)
                        .setLanguage(language),
                  ),
                ],
              ),
              loading: () => const Column(
                children: [AppSkeletonText(), AppGap.sm(), AppSkeletonText()],
              ),
              error: (error, _) => AppAlert(
                title: Text(l10n.settingsLoadError),
                subtitle: Text('$error'),
                variant: AppAlertVariant.destructive,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
