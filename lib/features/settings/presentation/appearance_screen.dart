import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';
import 'package:reader_documents/features/settings/application/settings_providers.dart';
import 'package:reader_documents/features/settings/data/app_settings.dart';
import 'package:reader_documents/l10n/app_localizations.dart';

import 'document_previews_settings_section.dart';
import 'documents_view_settings_section.dart';
import 'effects_settings_section.dart';
import 'palette_settings_section.dart';
import 'theme_settings_section.dart';

class AppearanceScreen extends ConsumerWidget {
  const AppearanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final settings = ref.watch(settingsProvider).value ?? AppSettings.defaults;
    final notifier = ref.read(settingsProvider.notifier);

    return AppScaffold(
      header: AppHeader(
        title: l10n.appearanceTitle,
        backLabel: l10n.goBack,
        onBackTap: () => Navigator.of(context).maybePop(),
      ),
      child: AppScrollArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppHeader.topInset(context) + AppSpacing.sm,
            AppSpacing.lg,
            MediaQuery.paddingOf(context).bottom + AppSpacing.xl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: AppSpacing.xl,
            children: [
              _AppearanceGroup(
                label: l10n.themeSectionTitle,
                child: ThemeSettingsSection(
                  themeMode: settings.themeMode,
                  onChanged: notifier.setThemeMode,
                ),
              ),
              _AppearanceGroup(
                label: l10n.paletteSectionTitle,
                child: PaletteSettingsSection(
                  palette: settings.palette,
                  onChanged: notifier.setPalette,
                ),
              ),
              _AppearanceGroup(
                label: l10n.graphicsSectionTitle,
                child: EffectsSettingsSection(
                  effectsMode: settings.effectsMode,
                  onChanged: notifier.setEffectsMode,
                ),
              ),
              _AppearanceGroup(
                label: l10n.documentsViewTitle,
                child: DocumentsViewSettingsSection(
                  layout: settings.documentsLayout,
                  onChanged: notifier.setDocumentsLayout,
                ),
              ),
              _AppearanceGroup(
                label: l10n.documentPreviewsTitle,
                child: DocumentPreviewsSettingsSection(
                  previews: settings.documentPreviews,
                  onChanged: notifier.setDocumentPreviews,
                ),
              ),
              _AppearanceGroup(
                label: l10n.readingSectionTitle,
                child: AppListGroup(
                  children: [
                    AppListRow(
                      title: l10n.warmFilterTitle,
                      subtitle: l10n.warmFilterHint,
                      leading: AppIcons.lamp,
                      onTap: notifier.toggleWarmReadingFilter,
                      trailing: AppSwitch(
                        value: settings.warmReadingFilter,
                        onChanged: (_) => notifier.toggleWarmReadingFilter(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AppearanceGroup extends StatelessWidget {
  const _AppearanceGroup({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    spacing: AppSpacing.sm,
    children: [
      Semantics(
        header: true,
        child: AppText(label, variant: AppTextVariant.overline),
      ),
      child,
    ],
  );
}
