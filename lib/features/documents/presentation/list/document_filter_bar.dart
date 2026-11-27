import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';
import 'package:reader_documents/l10n/app_localizations.dart';

import '../../application/documents_providers.dart';

class DocumentFilterBar extends ConsumerWidget {
  const DocumentFilterBar({
    required this.filter,
    required this.onChanged,
    super.key,
  });

  final DocumentFilter filter;
  final ValueChanged<DocumentFilter> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(documentStatsProvider).value;

    return AppChipBar(
      children: [
        AppChip(
          label: AppLocalizations.of(context)!.filterAll,
          count: stats?.count,
          selected: filter.isEmpty,
          onPressed: () => onChanged(filter.clear()),
        ),
        for (final type in DocumentFilter.selectable)
          AppChip(
            label: type.label,
            count: stats?.countByType[type] ?? 0,
            selected: filter.selects(type),
            onPressed: () => onChanged(filter.toggle(type)),
          ),
        for (final tag in filter.tags)
          AppChip(
            label: '#$tag',
            icon: AppIcons.x,
            selected: true,
            onPressed: () => onChanged(filter.toggleTag(tag)),
          ),
      ],
    );
  }
}
