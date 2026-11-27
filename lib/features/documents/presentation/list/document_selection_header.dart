import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';
import 'package:reader_documents/features/documents/data/models/document_file.dart';
import 'package:reader_documents/l10n/app_localizations.dart';

import '../../application/documents_providers.dart';
import '../actions/document_commands.dart';
import '../actions/document_sharing.dart';
import 'document_card_menu.dart';

class DocumentSelectionHeader extends ConsumerWidget {
  const DocumentSelectionHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final selection = ref.watch(documentSelectionProvider);
    final files = selection.files;
    final allSelected =
        selection.available.isNotEmpty &&
        files.length == selection.available.length;

    return AppSelectionHeader(
      title: l10n.selectionCount(files.length),
      closeLabel: l10n.cancel,
      onClose: () => _clear(ref),
      actions: [
        if (files.length == 1)
          AppSelectionAction(
            label: l10n.selectionDetails,
            icon: AppIcons.ellipsisVertical,
            onPressed: () => _openDetails(context, ref, files.first),
          ),
        AppSelectionAction(
          label: allSelected ? l10n.deselectAll : l10n.selectAll,
          icon: allSelected ? AppIcons.checkCheck : AppIcons.listChecks,
          onPressed: () =>
              ref.read(documentSelectionProvider.notifier).selectAll(),
        ),
      ],
    );
  }

  void _clear(WidgetRef ref) =>
      ref.read(documentSelectionProvider.notifier).clear();

  void _openDetails(BuildContext context, WidgetRef ref, DocumentFile file) =>
      DocumentCardMenu.show(
        context: context,
        ref: ref,
        file: file,
        confirmDelete: () => DocumentCommands.confirmDelete(context, file),
        onDelete: () async {
          await ref.read(documentsProvider.notifier).delete(file.path);
          _clear(ref);
        },
      );
}

class DocumentSelectionActionBar extends ConsumerWidget {
  const DocumentSelectionActionBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final files = ref.watch(documentSelectionProvider).files;
    final favorites = ref.watch(favoritesProvider).value ?? const <String>{};
    final allFavorite =
        files.isNotEmpty &&
        files.every((file) => favorites.contains(file.path));

    return AppSelectionActionBar(
      actions: [
        AppSelectionAction(
          label: allFavorite ? l10n.unfavoriteSelected : l10n.favoriteSelected,
          icon: AppIcons.star,
          onPressed: () => DocumentCommands.toggleFavoriteMany(
            context,
            ref,
            files.map((file) => file.path),
          ),
        ),
        AppSelectionAction(
          label: l10n.shareSelected,
          icon: AppIcons.share2,
          onPressed: () => DocumentSharing.shareMany(files),
        ),
        AppSelectionAction(
          label: l10n.deleteSelected,
          icon: AppIcons.trash2,
          destructive: true,
          onPressed: () => DocumentCommands.deleteSelection(
            context,
            ref,
            files,
            onDone: () => _clear(ref),
          ),
        ),
      ],
    );
  }

  void _clear(WidgetRef ref) =>
      ref.read(documentSelectionProvider.notifier).clear();
}

class DocumentSelectionAwareFooter extends ConsumerWidget {
  const DocumentSelectionAwareFooter({required this.normal, super.key});

  final Widget normal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selecting = ref.watch(documentSelectionProvider).isNotEmpty;
    return AnimatedSwitcher(
      duration: context.tokens.motion.quick,
      child: selecting
          ? const DocumentSelectionActionBar(key: ValueKey('selection'))
          : KeyedSubtree(key: const ValueKey('normal'), child: normal),
    );
  }
}
