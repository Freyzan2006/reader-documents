import 'package:flutter/widgets.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';
import 'package:reader_documents/l10n/app_localizations.dart';

class DocumentPasswordPrompt extends StatelessWidget {
  const DocumentPasswordPrompt({
    required this.incorrect,
    required this.controller,
    required this.onCancel,
    required this.onUnlock,
    super.key,
  });

  final bool incorrect;
  final TextEditingController controller;
  final VoidCallback onCancel;
  final VoidCallback onUnlock;

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
              Icon(AppIcons.lock, size: 40, color: colors.mutedForeground),
              AppText(l10n.pdfPasswordTitle, textAlign: TextAlign.center),
              if (incorrect)
                AppText(
                  l10n.pdfPasswordIncorrect,
                  variant: AppTextVariant.caption,
                  color: colors.destructive,
                  textAlign: TextAlign.center,
                ),
              AppInput(
                controller: controller,
                hint: l10n.pdfPasswordHint,
                obscureText: true,
                autofocus: true,
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                spacing: AppSpacing.sm,
                children: [
                  AppButton(
                    variant: AppButtonVariant.ghost,
                    onPressed: onCancel,
                    child: Text(l10n.cancel),
                  ),
                  AppButton(
                    onPressed: onUnlock,
                    child: Text(l10n.pdfPasswordUnlock),
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
