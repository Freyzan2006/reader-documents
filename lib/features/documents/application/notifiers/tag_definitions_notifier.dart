import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reader_documents/features/documents/data/models/tag_color.dart';
import 'package:reader_documents/features/documents/data/models/tag_definition.dart';

import '../providers/documents_providers.dart';

class TagDefinitionsNotifier extends AsyncNotifier<List<TagDefinition>> {
  @override
  Future<List<TagDefinition>> build() async =>
      await ref.read(tagDefinitionsRepositoryProvider).load() ?? const [];

  Future<void> upsert(String name, TagColor color) async {
    final current = state.value ?? const [];
    final updated = [
      for (final definition in current)
        if (definition.name != name) definition,
      TagDefinition(name: name, color: color),
    ];
    await ref.read(tagDefinitionsRepositoryProvider).save(updated);
    state = AsyncData(updated);
  }
}

final tagDefinitionsProvider =
    AsyncNotifierProvider<TagDefinitionsNotifier, List<TagDefinition>>(
      TagDefinitionsNotifier.new,
    );
