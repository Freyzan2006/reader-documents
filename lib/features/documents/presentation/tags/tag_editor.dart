import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';
import 'package:reader_documents/features/documents/data/tag_color.dart';
import 'package:reader_documents/features/documents/data/tag_definition.dart';
import 'package:reader_documents/l10n/app_localizations.dart';

import '../../application/documents_providers.dart';

abstract final class TagEditorSheet {
  static Future<void> show({
    required BuildContext context,
    required String documentPath,
  }) => AppSheet.show(
    context: context,
    initialSize: 0.5,
    builder: (context, scrollController) => TagEditorView(
      documentPath: documentPath,
      scrollController: scrollController,
    ),
  );
}

class TagEditorView extends ConsumerStatefulWidget {
  const TagEditorView({
    required this.documentPath,
    required this.scrollController,
    super.key,
  });

  final String documentPath;
  final ScrollController scrollController;

  @override
  ConsumerState<TagEditorView> createState() => _TagEditorViewState();
}

class _TagEditorViewState extends ConsumerState<TagEditorView> {
  final _controller = TextEditingController();
  TagColor _selectedColor = TagColor.values.first;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _addTag() {
    ref
        .read(tagsProvider.notifier)
        .addTag(widget.documentPath, _controller.text, _selectedColor);
    _controller.clear();
  }

  List<TagDefinition> _availableTags(List<String> currentTags) {
    final definitions = ref.watch(tagDefinitionsProvider).value ?? const [];
    return [
      for (final definition in definitions)
        if (!currentTags.contains(definition.name)) definition,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final tags = ref.watch(documentTagsProvider(widget.documentPath));

    return ListView(
      controller: widget.scrollController,
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        AppText(l10n.tagsTitle, variant: AppTextVariant.title),
        const AppGap.md(),
        if (tags.isEmpty)
          AppText(l10n.tagsEmpty, variant: AppTextVariant.caption)
        else
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final tag in tags)
                AppTag(
                  label: Text(tag),
                  color: ref.watch(tagColorProvider(tag)).value,
                  onRemove: () => ref
                      .read(tagsProvider.notifier)
                      .removeTag(widget.documentPath, tag),
                ),
            ],
          ),
        const AppGap.lg(),
        if (_availableTags(tags).isNotEmpty) ...[
          AppText(l10n.tagsExisting, variant: AppTextVariant.caption),
          const AppGap.sm(),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final definition in _availableTags(tags))
                AppTappable(
                  onPressed: () => ref
                      .read(tagsProvider.notifier)
                      .addTag(
                        widget.documentPath,
                        definition.name,
                        definition.color,
                      ),
                  child: AppBadge(
                    color: definition.color.value,
                    child: Text(definition.name),
                  ),
                ),
            ],
          ),
          const AppGap.lg(),
        ],
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final color in TagColor.values)
              _ColorSwatch(
                color: color,
                selected: color == _selectedColor,
                onTap: () => setState(() => _selectedColor = color),
              ),
          ],
        ),
        const AppGap.md(),
        Row(
          spacing: AppSpacing.sm,
          children: [
            Expanded(
              child: AppInput(controller: _controller, hint: l10n.tagsAddHint),
            ),
            AppButton(onPressed: _addTag, child: Text(l10n.tagsAdd)),
          ],
        ),
      ],
    );
  }
}

class _ColorSwatch extends StatelessWidget {
  const _ColorSwatch({
    required this.color,
    required this.selected,
    required this.onTap,
  });

  static const _size = 28.0;

  final TagColor color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => AppTappable(
    onPressed: onTap,
    child: SizedBox(
      width: _size,
      height: _size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: color.value,
          shape: BoxShape.circle,
          border: selected
              ? Border.all(color: AppColors.of(context).foreground, width: 2)
              : null,
        ),
      ),
    ),
  );
}
