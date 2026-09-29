import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';
import 'package:reader_documents/features/documents/data/models/tag_color.dart';
import 'package:reader_documents/features/documents/data/models/tag_definition.dart';
import 'package:reader_documents/features/documents/presentation/actions/document_commands.dart';

/// The loaded-data rendering for [HomeTagsSection] — every known tag as a
/// chip; tapping one jumps to the Documents tab filtered to it.
class HomeTagsChips extends ConsumerWidget {
  const HomeTagsChips({required this.tags, super.key});

  final List<TagDefinition> tags;

  @override
  Widget build(BuildContext context, WidgetRef ref) => Wrap(
    spacing: AppSpacing.sm,
    runSpacing: AppSpacing.sm,
    children: [
      for (final tag in tags)
        AppTag(
          label: Text(tag.name),
          color: tag.color.value,
          onRemove: () => DocumentCommands.browseByTag(ref, tag.name),
        ),
    ],
  );
}
