import 'package:flutter/widgets.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';
import 'package:reader_documents/features/documents/application/documents_providers.dart';
import 'package:reader_documents/features/documents/data/models/document_file.dart';
import 'package:reader_documents/l10n/app_localizations.dart';

import 'home_stat_tile.dart';

/// The loaded-data rendering for [HomeStatsSection]: two stat tiles, plus a
/// by-format breakdown once more than one format is present.
class HomeStatsContent extends StatelessWidget {
  const HomeStatsContent({required this.stats, super.key});

  final DocumentStats stats;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: AppSpacing.sm,
      children: [
        Row(
          spacing: AppSpacing.sm,
          children: [
            Expanded(
              child: HomeStatTile(
                icon: AppIcons.fileText,
                label: l10n.navDocuments,
                value: '${stats.count}',
              ),
            ),
            Expanded(
              child: HomeStatTile(
                icon: AppIcons.hardDrive,
                label: l10n.homeStatsTotalSize,
                value: DocumentFile.formatBytes(stats.totalBytes),
              ),
            ),
          ],
        ),
        if (stats.countByType.length > 1)
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              for (final entry in stats.countByType.entries)
                AppBadge(
                  variant: AppBadgeVariant.outline,
                  child: Text('${entry.key.label} · ${entry.value}'),
                ),
            ],
          ),
      ],
    );
  }
}
