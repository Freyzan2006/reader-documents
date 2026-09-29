import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reader_documents/features/documents/application/documents_providers.dart';
import 'package:reader_documents/l10n/app_localizations.dart';

import '../home_section_error_banner.dart';
import 'home_stats_content.dart';
import 'home_stats_skeleton.dart';

/// A compact strip under the Home title: document count, total size, and a
/// by-format breakdown. Hides itself while there's nothing to summarize. The
/// aggregation lives in [documentStatsProvider] — this only picks which of
/// [HomeStatsContent]/[HomeStatsSkeleton]/[HomeSectionErrorBanner] to show.
class HomeStatsSection extends ConsumerWidget {
  const HomeStatsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return ref
        .watch(documentStatsProvider)
        .when(
          data: (stats) => stats.count == 0
              ? const SizedBox.shrink()
              : HomeStatsContent(stats: stats),
          loading: () => const HomeStatsSkeleton(),
          error: (error, _) => HomeSectionErrorBanner(
            message: l10n.documentsLoadError,
            error: error,
          ),
        );
  }
}
