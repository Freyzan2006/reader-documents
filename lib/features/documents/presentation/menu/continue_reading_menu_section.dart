import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';
import 'package:reader_documents/features/documents/application/documents_providers.dart';
import 'package:reader_documents/features/documents/data/models/document_file.dart';
import 'package:reader_documents/l10n/app_localizations.dart';

import 'menu_document_tile.dart';

class ContinueReadingMenuSection extends ConsumerWidget {
  const ContinueReadingMenuSection({required this.onOpen, super.key});

  final ValueChanged<DocumentFile> onOpen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final file = ref.watch(mostRecentDocumentProvider).value;
    if (file == null) return const SizedBox.shrink();
    final progress = ref.watch(readingFractionProvider(file.path));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MenuSectionLabel(
          AppLocalizations.of(context)!.homeContinueReadingTitle,
        ),
        MenuDocumentTile(
          file: file,
          highlighted: true,
          onTap: () => onOpen(file),
          subtitle: progress == null
              ? AppText(file.type.label, variant: AppTextVariant.meta)
              : Row(
                  spacing: AppSpacing.sm,
                  children: [
                    Expanded(child: AppProgress(value: progress, height: 3)),
                    AppText(
                      '${(progress * 100).round()}%',
                      variant: AppTextVariant.meta,
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}
