import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart' show MaterialPageRoute;
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reader_documents/core/navigation/app_nav_tab.dart';
import 'package:reader_documents/core/navigation/navigation_providers.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';
import 'package:reader_documents/l10n/app_localizations.dart';

import '../../application/documents_providers.dart';
import '../../data/models/document_file.dart';
import '../favorites/favorites_screen.dart';
import '../viewer/document_viewer_factory.dart';
import '../viewer/document_viewer_screen.dart';

abstract final class DocumentCommands {
  static List<AppCommandItem> items(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return [
      AppCommandItem(
        label: l10n.importDocument,
        icon: AppIcons.upload,
        onSelect: () => importDocument(ref),
      ),
      AppCommandItem(
        label: l10n.homeFavoritesTitle,
        icon: AppIcons.star,
        onSelect: () => openFavorites(context),
      ),
    ];
  }

  static Future<void> openFavorites(BuildContext context) => Navigator.of(
    context,
  ).push(MaterialPageRoute<void>(builder: (_) => const FavoritesScreen()));

  static Future<void> importDocument(WidgetRef ref) async {
    final file = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: const ['pdf', 'docx', 'djvu'],
    );
    final path = file?.path;
    if (path == null) return;
    await ref.read(documentsProvider.notifier).import(path);
  }

  /// Sets the library filter to just [tag] and switches to the Documents
  /// tab — Home's "browse by tag" chips land here instead of duplicating
  /// filter/navigation logic in a widget.
  static void browseByTag(WidgetRef ref, String tag) {
    ref.read(documentFilterProvider.notifier).state = ref
        .read(documentFilterProvider)
        .withTag(tag);
    ref.read(currentNavDestinationProvider.notifier).state =
        AppNavDestination.documents;
  }

  static Future<void> open(
    BuildContext context,
    WidgetRef ref,
    DocumentFile file,
  ) async {
    await ref.read(recentlyOpenedProvider.notifier).markOpened(file.path);
    if (!context.mounted) return;

    if (!DocumentViewerFactory.supports(file.type)) {
      AppToast.show(
        context: context,
        title: Text(AppLocalizations.of(context)!.viewerComingSoon),
        description: Text(file.name),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => DocumentViewerScreen(file: file)),
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
