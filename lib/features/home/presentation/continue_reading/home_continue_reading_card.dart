import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';
import 'package:reader_documents/features/documents/application/documents_providers.dart';
import 'package:reader_documents/features/documents/data/models/document_file.dart';
import 'package:reader_documents/features/documents/presentation/actions/document_commands.dart';
import 'package:reader_documents/l10n/app_localizations.dart';
import 'package:reader_documents/features/documents/presentation/list/document_thumbnail.dart';

/// The tappable card inside [HomeContinueReadingSection] — title, format
/// icon, and the saved page if one exists (there's no persisted page count,
/// so this can only show a page number, not a percentage).
class HomeContinueReadingCard extends ConsumerWidget {
  const HomeContinueReadingCard({required this.file, this.onTap, super.key});

  final DocumentFile file;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final title = ref.watch(documentTitleProvider(file.path)) ?? file.name;
    final page = ref.watch(lastReadingProgressPageProvider(file.path)).value;
    final progress = ref.watch(readingFractionProvider(file.path));

    return AppContinueReadingCard(
      overline: l10n.homeContinueReadingTitle,
      title: title,
      meta: page == null ? file.type.label : l10n.bookmarkPageLabel(page),
      progress: progress,
      thumbnail: DocumentThumbnail.of(file),
      onTap: onTap ?? () => DocumentCommands.open(context, ref, file),
    );
  }
}
