import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';
import 'package:reader_documents/features/documents/application/documents_providers.dart';
import 'package:reader_documents/features/documents/presentation/actions/document_commands.dart';
import 'package:reader_documents/features/documents/presentation/list/document_list.dart';
import 'package:reader_documents/l10n/app_localizations.dart';

import '../../application/providers/home_recent_documents_provider.dart';

/// The rest of the recently-opened history (the single most-recent document
/// already has its own "continue reading" card above). Hides itself when
/// there's nothing beyond what that card already shows — but still shows its
/// usual empty state when nothing has ever been opened at all.
class HomeRecentSection extends ConsumerWidget {
  const HomeRecentSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mostRecent = ref.watch(mostRecentDocumentProvider).value;
    final older = ref.watch(homeOlderDocumentsProvider);
    if (mostRecent != null && (older.value?.isEmpty ?? false)) {
      return const SizedBox.shrink();
    }

    final l10n = AppLocalizations.of(context)!;
    return AppSection(
      title: l10n.homeRecentTitle,
      icon: AppIcons.history,
      child: DocumentList(
        documents: older,
        emptyMessage: l10n.homeRecentEmpty,
        skeletonCount: 5,
        onOpen: (file) => DocumentCommands.open(context, ref, file),
        confirmDelete: (file) => DocumentCommands.confirmDelete(context, file),
        onDelete: (file) =>
            ref.read(documentsProvider.notifier).delete(file.path),
      ),
    );
  }
}
