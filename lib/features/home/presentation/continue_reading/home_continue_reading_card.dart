import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';
import 'package:reader_documents/features/documents/application/documents_providers.dart';
import 'package:reader_documents/features/documents/data/models/document_file.dart';
import 'package:reader_documents/features/documents/presentation/actions/document_commands.dart';
import 'package:reader_documents/features/documents/presentation/list/document_icon.dart';
import 'package:reader_documents/l10n/app_localizations.dart';

/// The tappable card inside [HomeContinueReadingSection] — title, format
/// icon, and the saved page if one exists (there's no persisted page count,
/// so this can only show a page number, not a percentage).
class HomeContinueReadingCard extends ConsumerWidget {
  const HomeContinueReadingCard({required this.file, super.key});

  final DocumentFile file;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final title = ref.watch(documentTitleProvider(file.path)) ?? file.name;
    final page = ref.watch(lastReadingProgressPageProvider(file.path)).value;
    final offset = ref.watch(lastReadingOffsetProvider(file.path)).value;
    // Clamped because the value comes off disk and FDeterminateProgress asserts
    // its argument into 0..1 — a stale or hand-edited key would otherwise take
    // the whole home screen down. Null for paginated documents, which save a
    // page number instead, so only DOCX grows a bar.
    final progress = offset?.clamp(0.0, 1.0);

    return AppTappable(
      onPressed: () => DocumentCommands.open(context, ref, file),
      child: AppCard(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          spacing: AppSpacing.md,
          children: [
            DocumentIcon(type: file.type, size: 28),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: AppSpacing.xs,
                children: [
                  AppText(
                    title,
                    variant: AppTextVariant.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (page != null)
                    AppText(
                      l10n.bookmarkPageLabel(page),
                      variant: AppTextVariant.caption,
                    ),
                  if (progress != null) AppProgress(value: progress),
                ],
              ),
            ),
            const Icon(AppIcons.arrowRight, size: 18),
          ],
        ),
      ),
    );
  }
}
