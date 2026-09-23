import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart' show FLucideIcons;

import '../core/ui_kit/ui_kit.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) => AppScrollArea(
    child: Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppHeader.topInset(context) + AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppText('Recent documents', variant: AppTextVariant.title),
          const AppGap.sm(),
          AppList(
            items: [
              AppListItem(
                title: 'Quarterly report.pdf',
                subtitle: 'Edited 2h ago',
                leading: FLucideIcons.fileText,
                onTap: () {},
              ),
              AppListItem(
                title: 'Meeting notes.docx',
                subtitle: 'Edited yesterday',
                leading: FLucideIcons.fileText,
                onTap: () {},
              ),
              AppListItem(
                title: 'Scanned contract.djvu',
                subtitle: 'Edited last week',
                leading: FLucideIcons.fileText,
                onTap: () {},
              ),
            ],
          ),
          const AppGap.lg(),
          const AppText('Folders', variant: AppTextVariant.title),
          const AppGap.sm(),
          AppGrid(
            children: [
              for (final label in ['Recent', 'Favorites', 'Shared', 'Trash'])
                DecoratedBox(
                  decoration: BoxDecoration(
                    border: AppBorders.all(context),
                    borderRadius: AppRadius.of(context).md,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: AppText(label),
                  ),
                ),
            ],
          ),
        ],
      ),
    ),
  );
}
