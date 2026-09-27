import 'package:flutter/widgets.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';
import 'package:reader_documents/l10n/app_localizations.dart';

class DocumentErrorView extends StatelessWidget {
  const DocumentErrorView({
    required this.isPasswordProtected,
    required this.onBack,
    super.key,
  });

  final bool isPasswordProtected;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = AppColors.of(context);

    return ColoredBox(
      color: colors.background,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: AppSpacing.md,
            children: [
              Icon(
                isPasswordProtected ? AppIcons.lock : AppIcons.fileWarning,
                size: 40,
                color: colors.mutedForeground,
              ),
              AppText(
                isPasswordProtected
                    ? l10n.pdfErrorPasswordProtected
                    : l10n.pdfErrorGeneric,
                textAlign: TextAlign.center,
                color: colors.mutedForeground,
              ),
              AppButton(
                onPressed: onBack,
                variant: AppButtonVariant.secondary,
                mainAxisSize: MainAxisSize.min,
                child: AppText(l10n.goBack),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
