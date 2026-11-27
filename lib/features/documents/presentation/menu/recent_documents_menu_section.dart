import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';
import 'package:reader_documents/features/documents/application/documents_providers.dart';
import 'package:reader_documents/features/documents/data/models/document_file.dart';
import 'package:reader_documents/l10n/app_localizations.dart';

import 'menu_document_tile.dart';
import 'opened_ago.dart';

class RecentDocumentsMenuSection extends ConsumerWidget {
  const RecentDocumentsMenuSection({required this.onOpen, super.key});

  static const _limit = 3;

  final ValueChanged<DocumentFile> onOpen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final recent = ref.watch(recentDocumentsProvider).value ?? const [];
    final opened = ref.watch(recentlyOpenedProvider).value ?? const {};
    final older = recent.skip(1).take(_limit).toList();
    if (older.isEmpty) return const SizedBox.shrink();
    final ago = OpenedAgo(l10n, DateTime.now());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 2,
      children: [
        MenuSectionLabel(l10n.menuRecentTitle),
        for (final file in older)
          MenuDocumentTile(
            file: file,
            onTap: () => onOpen(file),
            subtitle: AppText(
              opened[file.path] == null
                  ? file.type.label
                  : ago.format(opened[file.path]!),
              variant: AppTextVariant.meta,
            ),
          ),
      ],
    );
  }
}
