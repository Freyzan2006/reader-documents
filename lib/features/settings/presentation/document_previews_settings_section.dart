import 'package:flutter/widgets.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';
import 'package:reader_documents/features/settings/data/app_settings.dart';
import 'package:reader_documents/l10n/app_localizations.dart';

class DocumentPreviewsSettingsSection extends StatelessWidget {
  const DocumentPreviewsSettingsSection({
    required this.previews,
    required this.onChanged,
    super.key,
  });

  final DocumentPreviews previews;
  final ValueChanged<DocumentPreviews> onChanged;

  static String _label(AppLocalizations l10n, DocumentPreviews value) =>
      switch (value) {
        DocumentPreviews.auto => l10n.documentsViewAuto,
        DocumentPreviews.show => l10n.documentPreviewsShow,
        DocumentPreviews.hide => l10n.documentPreviewsHide,
      };

  static List<AppThumbnailPreviewKind> _previewKinds(DocumentPreviews value) =>
      switch (value) {
        DocumentPreviews.auto => const [
          AppThumbnailPreviewKind.page,
          AppThumbnailPreviewKind.placeholder,
        ],
        DocumentPreviews.show => const [AppThumbnailPreviewKind.page],
        DocumentPreviews.hide => const [AppThumbnailPreviewKind.placeholder],
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final resolved = DocumentPreviews.auto.enabled(context.tokens.graphics)
        ? l10n.switchOn
        : l10n.switchOff;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppSpacing.sm,
      children: [
        Semantics(
          container: true,
          label: l10n.documentPreviewsTitle,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: AppSpacing.sm,
              children: [
                for (final value in DocumentPreviews.values)
                  Expanded(
                    child: AppPreviewChoiceCard(
                      label: _label(l10n, value),
                      sub: value == DocumentPreviews.auto
                          ? l10n.nowValue(resolved)
                          : null,
                      preview: AppThumbnailPreview(kinds: _previewKinds(value)),
                      selected: value == previews,
                      onPressed: () => onChanged(value),
                    ),
                  ),
              ],
            ),
          ),
        ),
        AppText(l10n.documentPreviewsHint, variant: AppTextVariant.caption),
      ],
    );
  }
}
