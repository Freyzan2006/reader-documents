import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';
import 'package:reader_documents/l10n/app_localizations.dart';

import '../application/settings_providers.dart';
import 'about_settings_card.dart';
import 'language_settings_card.dart';
import 'profile_settings_card.dart';
import 'settings_welcome_title.dart';
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
          spacing: AppSpacing.xl,
          children: [
            const SettingsWelcomeTitle(),
            settings.when(
              data: (value) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: AppSpacing.xl,
                children: [
                  _Section(
                    title: l10n.profileSectionTitle,
                    child: ProfileSettingsCard(
                      profile: value.profile,
                      onSave: (profile) => ref
                          .read(settingsProvider.notifier)
                          .updateProfile(profile),
                    ),
                  ),
                  _Section(
                    title: l10n.themeSectionTitle,
                    child: ThemeSettingsCard(
                      themeMode: value.themeMode,
                      onChanged: (mode) => ref
                          .read(settingsProvider.notifier)
                          .setThemeMode(mode),
                    ),
                  ),
                  _Section(
                    title: l10n.languageSectionTitle,
                    child: LanguageSettingsCard(
                      language: value.language,
                      onChanged: (language) => ref
                          .read(settingsProvider.notifier)
                          .setLanguage(language),
                    ),
                  ),
                  _Section(
                    title: l10n.aboutSectionTitle,
                    child: const AboutSettingsCard(),
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

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: AppSpacing.sm,
      children: [
        AppText(title, variant: AppTextVariant.subtitle),
        child,
      ],
    );
  }
}
