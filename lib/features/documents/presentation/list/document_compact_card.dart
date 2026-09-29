import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';
import 'package:reader_documents/features/documents/data/models/document_file.dart';

import '../../application/documents_providers.dart';
import 'document_icon.dart';

/// A narrow, fixed-width variant of [DocumentCard] for horizontal shelves
/// (e.g. Home's favorites row) — the full card assumes it owns the row's
/// entire width, so it isn't reusable there as-is.
class DocumentCompactCard extends ConsumerWidget {
  const DocumentCompactCard({required this.file, this.onTap, super.key});

  static const _width = 148.0;

  final DocumentFile file;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final title = ref.watch(documentTitleProvider(file.path)) ?? file.name;

    return SizedBox(
      width: _width,
      child: AppTappable(
        onPressed: onTap,
        child: AppCard(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: AppSpacing.sm,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  DocumentIcon(type: file.type),
                  Icon(
                    AppIcons.star,
                    size: 16,
                    color: AppColors.warning(context),
                  ),
                ],
              ),
              AppText(
                title,
                variant: AppTextVariant.subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              AppBadge(
                variant: AppBadgeVariant.secondary,
                child: Text(file.type.label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
