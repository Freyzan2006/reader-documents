import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';
import 'package:reader_documents/features/documents/application/documents_providers.dart';
import 'package:reader_documents/features/documents/data/models/document_file.dart';
import 'package:reader_documents/features/home/presentation/continue_reading/home_continue_reading_card.dart';
import 'package:reader_documents/l10n/app_localizations.dart';

class ContinueReadingMenuSection extends ConsumerWidget {
  const ContinueReadingMenuSection({required this.onOpen, super.key});

  final ValueChanged<DocumentFile> onOpen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final file = ref.watch(mostRecentDocumentProvider).value;
    if (file == null) return const SizedBox.shrink();

    return AppSection(
      variant: AppSectionVariant.compact,
      title: AppLocalizations.of(context)!.homeContinueReadingTitle,
      icon: AppIcons.bookOpen,
      child: HomeContinueReadingCard(file: file, onTap: () => onOpen(file)),
    );
  }
}
