import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reader_documents/core/config/app_brand.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';
import 'package:reader_documents/features/documents/application/documents_providers.dart';
import 'package:reader_documents/features/documents/data/models/document_file.dart';
import 'package:reader_documents/l10n/app_localizations.dart';

class SideMenuBrand extends ConsumerWidget {
  const SideMenuBrand({super.key});

  static const _markSize = 40.0;
  static const _logoWidth = 30.0;
  static const _markColor = Color(0xFF000000);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final stats = ref.watch(documentStatsProvider).value;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.xl,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      child: Row(
        spacing: AppSpacing.md,
        children: [
          Container(
            width: _markSize,
            height: _markSize,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: _markColor,
              borderRadius: AppRadii.sm,
            ),
            child: Image.asset(
              'assets/icon/launch_logo.png',
              width: _logoWidth,
              filterQuality: FilterQuality.medium,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 2,
              children: [
                AppText(
                  AppBrand.name,
                  variant: AppTextVariant.item,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (stats != null)
                  AppText(
                    '${l10n.menuDocumentsCount(stats.count)} · '
                    '${DocumentFile.formatBytes(stats.totalBytes)}',
                    variant: AppTextVariant.meta,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
