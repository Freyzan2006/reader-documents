import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart' show MaterialPageRoute;
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';
import 'package:reader_documents/l10n/app_localizations.dart';

import '../application/documents_providers.dart';
import '../data/document_file.dart';
import 'pdf_viewer_screen.dart';

abstract final class DocumentCommands {
  static List<AppCommandItem> items(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return [
      AppCommandItem(
        label: l10n.importDocument,
        icon: AppIcons.upload,
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

  static Future<void> open(
    BuildContext context,
    WidgetRef ref,
    DocumentFile file,
  ) async {
    await ref.read(recentlyOpenedProvider.notifier).markOpened(file.path);
    if (!context.mounted) return;

    if (file.type == DocumentType.pdf) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => PdfViewerScreen(file: file)),
      );
      return;
    }

    AppToast.show(
      context: context,
      title: Text(AppLocalizations.of(context)!.viewerComingSoon),
      description: Text(file.name),
    );
  }

  static Future<bool> confirmDelete(
    BuildContext context,
    DocumentFile file,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final bodyParts = l10n.deleteDocumentBody(file.name).split(file.name);
    final confirmed = await AppDialog.show<bool>(
      context: context,
      title: Text(l10n.deleteDocumentTitle),
      body: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: bodyParts[0],
              style: AppText.styleOf(context, AppTextVariant.body),
            ),
            TextSpan(
              text: file.name,
              style: AppText.styleOf(context, AppTextVariant.annotation),
            ),
            if (bodyParts.length > 1)
              TextSpan(
                text: bodyParts[1],
                style: AppText.styleOf(context, AppTextVariant.body),
              ),
          ],
        ),
      ),
      actions: [
        AppButton(
          variant: AppButtonVariant.outline,
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.cancel),
        ),
        AppButton(
          variant: AppButtonVariant.destructive,
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(l10n.delete),
        ),
      ],
    );
    return confirmed ?? false;
  }
}
