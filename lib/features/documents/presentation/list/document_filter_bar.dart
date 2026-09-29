import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';
import 'package:reader_documents/features/documents/data/models/tag_color.dart';
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
  Widget build(BuildContext context, WidgetRef ref) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 3,
        children: [
          AppButton(
            variant: filter.isEmpty
                ? AppButtonVariant.primary
                : AppButtonVariant.outline,
            size: AppButtonSize.sm,
            mainAxisSize: MainAxisSize.min,
            onPressed: () => onChanged(filter.clear()),
            child: Text(AppLocalizations.of(context)!.filterAll),
          ),
          for (final type in DocumentFilter.selectable)
            AppButton(
              variant: filter.selects(type)
                  ? AppButtonVariant.primary
                  : AppButtonVariant.outline,
              size: AppButtonSize.sm,
              mainAxisSize: MainAxisSize.min,
              onPressed: () => onChanged(filter.toggle(type)),
              child: Text(type.label),
            ),
        ],
      ),
      if (!filter.isEmpty) ...[
        const AppGap.sm(),
        Wrap(
          spacing: AppSpacing.sm,
          children: [
            for (final type in filter.types)
              AppTag(
                label: Text(type.label),
                onRemove: () => onChanged(filter.toggle(type)),
              ),
            for (final tag in filter.tags)
              AppTag(
                label: Text(tag),
                color: ref.watch(tagColorProvider(tag)).value,
                onRemove: () => onChanged(filter.toggleTag(tag)),
              ),
          ],
        ),
      ],
    ],
  );
}
