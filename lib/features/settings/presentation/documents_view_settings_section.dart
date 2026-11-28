import 'package:flutter/widgets.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';
import 'package:reader_documents/features/settings/data/app_settings.dart';
import 'package:reader_documents/l10n/app_localizations.dart';

class DocumentsViewSettingsSection extends StatelessWidget {
  const DocumentsViewSettingsSection({
    required this.layout,
    required this.onChanged,
    super.key,
  });

  final DocumentsLayout layout;
  final ValueChanged<DocumentsLayout> onChanged;

  static String label(AppLocalizations l10n, DocumentsLayout layout) =>
      switch (layout) {
        DocumentsLayout.auto => l10n.documentsViewAuto,
        DocumentsLayout.card => l10n.documentsViewCard,
        DocumentsLayout.cardrow => l10n.documentsViewCardRow,
      };

  static List<AppLayoutPreviewKind> _previewKinds(DocumentsLayout layout) =>
      switch (layout) {
        DocumentsLayout.auto => const [
          AppLayoutPreviewKind.rows,
          AppLayoutPreviewKind.grid,
        ],
        DocumentsLayout.card => const [AppLayoutPreviewKind.rows],
        DocumentsLayout.cardrow => const [AppLayoutPreviewKind.grid],
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final resolved = DocumentsLayout.auto.useCardRow(context.screenSize)
        ? DocumentsLayout.cardrow
        : DocumentsLayout.card;

    return Semantics(
      container: true,
      label: l10n.documentsViewTitle,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: AppSpacing.sm,
          children: [
            for (final value in DocumentsLayout.values)
              Expanded(
                child: AppPreviewChoiceCard(
                  label: label(l10n, value),
                  sub: value == DocumentsLayout.auto
                      ? l10n.nowValue(label(l10n, resolved).toLowerCase())
                      : null,
                  preview: AppLayoutPreview(kinds: _previewKinds(value)),
                  selected: value == layout,
                  onPressed: () => onChanged(value),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
