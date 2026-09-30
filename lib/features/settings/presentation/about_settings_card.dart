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
        spacing: AppSpacing.sm,
        children: [
          AppText(l10n.aboutSectionTitle, variant: AppTextVariant.subtitle),
          AppText(
            l10n.appVersion(AppBrand.version),
            variant: AppTextVariant.caption,
          ),
          AppTappable(
            onPressed: () {},
            child: AppText(
              l10n.privacyPolicy,
              variant: AppTextVariant.body,
              color: AppColors.accent(context),
            ),
          ),
          AppTappable(
            onPressed: () {},
            child: AppText(
              l10n.support,
              variant: AppTextVariant.body,
              color: AppColors.accent(context),
            ),
          ),
        ],
      ),
    );
  }
}
