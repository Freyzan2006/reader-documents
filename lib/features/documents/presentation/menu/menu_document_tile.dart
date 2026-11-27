import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';
import 'package:reader_documents/features/documents/application/documents_providers.dart';
import 'package:reader_documents/features/documents/data/models/document_file.dart';
import 'package:reader_documents/features/documents/presentation/list/document_mini_thumbnail.dart';

class MenuDocumentTile extends ConsumerWidget {
  const MenuDocumentTile({
    required this.file,
    required this.subtitle,
    required this.onTap,
    this.highlighted = false,
    super.key,
  });

  static const _thumbWidth = 30.0;

  final DocumentFile file;
  final Widget subtitle;
  final VoidCallback onTap;
  final bool highlighted;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.tokens.palette;
    final title = ref.watch(documentTitleProvider(file.path)) ?? file.name;

    return AppTappable(
      onPressed: onTap,
      semanticsLabel: title,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: highlighted ? palette.shade : null,
          borderRadius: AppRadii.sm,
        ),
        child: Row(
          spacing: AppSpacing.md,
          children: [
            DocumentMiniThumbnail(file: file, width: _thumbWidth),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 2,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.body.copyWith(
                      color: palette.ink,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MenuSectionLabel extends StatelessWidget {
  const MenuSectionLabel(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(
      AppSpacing.md,
      0,
      AppSpacing.md,
      AppSpacing.xs,
    ),
    child: Semantics(
      header: true,
      child: AppText(label, variant: AppTextVariant.overline),
    ),
  );
}
