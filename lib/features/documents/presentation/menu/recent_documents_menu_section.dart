import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';
import 'package:reader_documents/features/documents/application/documents_providers.dart';
import 'package:reader_documents/features/documents/data/models/document_file.dart';
import 'package:reader_documents/features/documents/presentation/list/document_icon.dart';
import 'package:reader_documents/l10n/app_localizations.dart';

class RecentDocumentsMenuSection extends ConsumerWidget {
  const RecentDocumentsMenuSection({required this.onOpen, super.key});

  final ValueChanged<DocumentFile> onOpen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recent = ref.watch(recentDocumentsProvider).value ?? const [];
    final older = recent.skip(1).toList();
    if (older.isEmpty) return const SizedBox.shrink();

    return AppSection(
      variant: AppSectionVariant.compact,
      title: AppLocalizations.of(context)!.menuRecentTitle,
      icon: AppIcons.history,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final file in older)
            _RecentDocumentTile(file: file, onTap: () => onOpen(file)),
        ],
      ),
    );
  }
}

class _RecentDocumentTile extends ConsumerWidget {
  const _RecentDocumentTile({required this.file, required this.onTap});

  final DocumentFile file;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final title = ref.watch(documentTitleProvider(file.path)) ?? file.name;

    return AppTappable(
      onPressed: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Row(
          spacing: AppSpacing.md,
          children: [
            DocumentIcon(type: file.type),
            Expanded(
              child: AppText(
                title,
                variant: AppTextVariant.body,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            AppText(file.type.label, variant: AppTextVariant.caption),
          ],
        ),
      ),
    );
  }
}
