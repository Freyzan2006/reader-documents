import 'package:file_picker/file_picker.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart' show FLucideIcons;
import 'package:reader_documents/core/ui_kit/ui_kit.dart';
import 'package:reader_documents/l10n/app_localizations.dart';

import '../application/documents_providers.dart';

abstract final class DocumentCommands {
  static List<AppCommandItem> items(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return [
      AppCommandItem(
        label: l10n.importDocument,
        icon: FLucideIcons.upload,
        onSelect: () => importDocument(ref),
      ),
    ];
  }

  static Future<void> importDocument(WidgetRef ref) async {
    final file = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: const ['pdf', 'docx', 'djvu'],
    );
    final path = file?.path;
    if (path == null) return;
    await ref.read(documentsProvider.notifier).import(path);
  }
}
