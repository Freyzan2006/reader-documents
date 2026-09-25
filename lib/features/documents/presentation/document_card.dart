import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart' show FLucideIcons, FTappable;
import 'package:reader_documents/core/ui_kit/ui_kit.dart';
import 'package:reader_documents/features/documents/data/document_file.dart';

class DocumentCard extends StatelessWidget {
  const DocumentCard({required this.file, this.onTap, super.key});

  static const _maxNameChars = 20;

  final DocumentFile file;
  final VoidCallback? onTap;

  String get _displayName => file.name.length > _maxNameChars
      ? '${file.name.substring(0, _maxNameChars - 3)}...'
      : file.name;

  static String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) => FTappable(
    onPress: onTap,
    child: AppCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        spacing: AppSpacing.sm,
        children: [
          const Icon(FLucideIcons.fileText, size: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: AppSpacing.xs,
              children: [
                AppText(_displayName),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: AppSpacing.xs,
                  children: [
                    AppBadge(
                      variant: AppBadgeVariant.secondary,
                      child: Text(file.type.label),
                    ),
                    AppBadge(
                      variant: AppBadgeVariant.outline,
                      child: Text(_formatSize(file.sizeBytes)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class DocumentCardSkeleton extends StatelessWidget {
  const DocumentCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) => AppCard(
    padding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.md,
      vertical: AppSpacing.sm,
    ),
    child: Row(
      spacing: AppSpacing.sm,
      children: [
        const AppSkeleton.circle(size: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: AppSpacing.xs,
            children: [
              const AppSkeleton(width: 120, height: 14),
              Row(
                mainAxisSize: MainAxisSize.min,
                spacing: AppSpacing.xs,
                children: const [
                  AppSkeleton(width: 40, height: 20),
                  AppSkeleton(width: 56, height: 20),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
