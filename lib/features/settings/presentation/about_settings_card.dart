import 'package:flutter/widgets.dart';
import 'package:reader_documents/core/config/app_brand.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';
import 'package:reader_documents/l10n/app_localizations.dart';

class AboutSettingsCard extends StatelessWidget {
  const AboutSettingsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: AppSpacing.xs,
        children: [
          AppText(l10n.aboutSectionTitle, variant: AppTextVariant.subtitle),
          AppText(AppBrand.name, variant: AppTextVariant.body),
          AppText(
            // Both parts are already loaded by AppBrand.load() at startup;
            // the build number is what distinguishes two installs of the same
            // version, so it's worth showing.
            l10n.appVersion(
              '${AppBrand.version} (${AppBrand.buildNumber})',
            ),
            variant: AppTextVariant.caption,
          ),
        ],
      ),
    );
  }
}