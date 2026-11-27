import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reader_documents/features/documents/application/documents_providers.dart';
import 'package:reader_documents/l10n/app_localizations.dart';

import '../home_section_error_banner.dart';
import 'home_continue_reading_card.dart';
import 'home_continue_reading_skeleton.dart';

/// The most-recently-opened document. Hides itself when nothing has ever
/// been opened.
class HomeContinueReadingSection extends ConsumerWidget {
  const HomeContinueReadingSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return ref
        .watch(mostRecentDocumentProvider)
        .when(
          data: (file) => file == null
              ? const SizedBox.shrink()
              : HomeContinueReadingCard(file: file),
          loading: () => const HomeContinueReadingSkeleton(),
          error: (error, _) => HomeSectionErrorBanner(
            message: l10n.documentsLoadError,
            error: error,
          ),
        );
  }
}
