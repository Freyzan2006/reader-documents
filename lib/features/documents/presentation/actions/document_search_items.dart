import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';

import '../../application/documents_providers.dart';
import '../../data/models/document_file.dart';
import '../list/document_icon.dart';
import 'document_commands.dart';

abstract final class DocumentSearchItems {
  static List<AppCommandItem> recent(BuildContext context, WidgetRef ref) => [
    for (final file in ref.read(recentDocumentsProvider).value ?? const [])
      _item(context, ref, file),
  ];

  static List<AppCommandItem> all(BuildContext context, WidgetRef ref) => [
    for (final file in ref.read(documentsProvider).value ?? const [])
      _item(context, ref, file),
  ];

  static AppCommandItem _item(
    BuildContext context,
    WidgetRef ref,
    DocumentFile file,
  ) {
    final tags = ref.read(documentTagsProvider(file.path));

    return AppCommandItem(
      label: ref.read(documentTitleProvider(file.path)) ?? file.name,
      leading: DocumentIcon(type: file.type),
      subtitle: [file.type.label, ...tags].join(' · '),
      keywords: [file.name, ...tags],
      onSelect: () => DocumentCommands.open(context, ref, file),
    );
  }
}
