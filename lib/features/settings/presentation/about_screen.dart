import 'package:flutter/widgets.dart';
import 'package:reader_documents/core/config/app_brand.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';
import 'package:reader_documents/l10n/app_localizations.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static String version() => '${AppBrand.version} (${AppBrand.buildNumber})';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AppScaffold(
      header: AppHeader(
        title: l10n.aboutSectionTitle,
        backLabel: l10n.goBack,
        onBackTap: () => Navigator.of(context).maybePop(),
      ),
      child: AppScrollArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppHeader.topInset(context) + AppSpacing.lg,
            AppSpacing.lg,
            MediaQuery.paddingOf(context).bottom + AppSpacing.xl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: AppSpacing.xl,
            children: [
              _AboutHero(tagline: l10n.aboutTagline, version: version()),
              AppListGroup(
                children: [
                  for (final (icon, title, body) in [
                    (
                      AppIcons.megaphoneOff,
                      l10n.aboutNoAdsTitle,
                      l10n.aboutNoAdsBody,
                    ),
                    (
                      AppIcons.shieldCheck,
                      l10n.aboutPrivacyTitle,
                      l10n.aboutPrivacyBody,
                    ),
                    (AppIcons.gift, l10n.aboutFreeTitle, l10n.aboutFreeBody),
                    (
                      AppIcons.files,
                      l10n.aboutFormatsTitle,
                      l10n.aboutFormatsBody,
                    ),
                  ])
                    AppListRow(
                      title: title,
                      subtitle: body,
                      prefix: _FeatureIcon(icon: icon),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AboutHero extends StatelessWidget {
  const _AboutHero({required this.tagline, required this.version});

  final String tagline;
  final String version;

  @override
  Widget build(BuildContext context) {
    final palette = context.tokens.palette;
    final l10n = AppLocalizations.of(context)!;

    return Column(
      spacing: AppSpacing.sm,
      children: [
        SizedBox.square(
          dimension: 64,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: palette.ink,
              borderRadius: AppRadii.lg,
            ),
            child: Icon(AppIcons.bookOpen, size: 30, color: palette.onInk),
          ),
        ),
        const AppGap.xs(),
        AppText(
          AppBrand.name,
          variant: AppTextVariant.title,
          textAlign: TextAlign.center,
        ),
        AppText(
          tagline,
          variant: AppTextVariant.caption,
          textAlign: TextAlign.center,
        ),
        AppText(
          '${l10n.aboutVersion} $version',
          variant: AppTextVariant.meta,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _FeatureIcon extends StatelessWidget {
  const _FeatureIcon({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final palette = context.tokens.palette;

    return SizedBox.square(
      dimension: 32,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: palette.shade,
          borderRadius: AppRadii.sm,
        ),
        child: Icon(icon, size: 18, color: palette.ink),
      ),
    );
  }
}
